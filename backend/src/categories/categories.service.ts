import { Injectable, ConflictException, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';

@Injectable()
export class CategoriesService {
  constructor(private prisma: PrismaService) {}

  private _generateSlug(name: string): string {
    return name
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-');
  }

  private async _checkCircularReference(categoryId: string, parentId: string): Promise<void> {
    if (categoryId === parentId) {
      throw new BadRequestException('A category cannot be its own parent');
    }

    let currentParentId: string | null = parentId;
    while (currentParentId) {
      const parentCategory: any = await this.prisma.category.findUnique({
        where: { id: currentParentId },
        select: { id: true, parentId: true },
      });

      if (!parentCategory) break;

      if (parentCategory.parentId === categoryId) {
        throw new BadRequestException('Circular relationship detected: Parent category is a descendant');
      }

      currentParentId = parentCategory.parentId;
    }
  }

  async create(dto: CreateCategoryDto) {
    const slug = dto.slug ? dto.slug.toLowerCase().trim() : this._generateSlug(dto.name);

    // Duplicate check
    const duplicate = await this.prisma.category.findFirst({
      where: {
        OR: [
          { name: { equals: dto.name, mode: 'insensitive' } },
          { slug },
        ],
      },
    });

    if (duplicate) {
      throw new ConflictException('Category name or slug already exists');
    }

    if (dto.parentId) {
      const parent = await this.prisma.category.findUnique({
        where: { id: dto.parentId },
      });
      if (!parent) {
        throw new NotFoundException('Parent category not found');
      }
    }

    return this.prisma.category.create({
      data: {
        name: dto.name,
        slug,
        description: dto.description,
        image: dto.image,
        displayOrder: dto.displayOrder ?? 0,
        status: (dto.status as any) ?? 'ACTIVE',
        parentId: dto.parentId,
      },
    });
  }

  async findAll(filters: {
    status?: 'ACTIVE' | 'INACTIVE' | 'ARCHIVED';
    parentId?: string;
    search?: string;
    sortBy?: 'name' | 'displayOrder' | 'createdAt';
    sortOrder?: 'asc' | 'desc';
  }) {
    const where: any = {
      deletedAt: null,
    };

    if (filters.status) {
      where.status = filters.status;
    }
    if (filters.parentId) {
      where.parentId = filters.parentId;
    }
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { description: { contains: filters.search, mode: 'insensitive' } },
      ];
    }

    const orderBy: any = {};
    const field = filters.sortBy ?? 'displayOrder';
    orderBy[field] = filters.sortOrder ?? 'asc';

    return this.prisma.category.findMany({
      where,
      orderBy,
      include: {
        _count: {
          select: { products: true },
        },
      },
    });
  }

  async getTree() {
    const all = await this.prisma.category.findMany({
      where: { deletedAt: null },
      orderBy: { displayOrder: 'asc' },
    });

    // Build hierarchical tree
    const rootNodes = all.filter(c => !c.parentId);
    
    const buildTree = (nodes: any[]): any[] => {
      return nodes.map(node => {
        const children = all.filter(c => c.parentId === node.id);
        return {
          ...node,
          children: children.length > 0 ? buildTree(children) : [],
        };
      });
    };

    return buildTree(rootNodes);
  }

  async findOne(id: string) {
    const category = await this.prisma.category.findFirst({
      where: { id, deletedAt: null },
      include: {
        parent: true,
        children: true,
      },
    });

    if (!category) {
      throw new NotFoundException('Category not found');
    }

    return category;
  }

  async update(id: string, dto: UpdateCategoryDto) {
    const category = await this.findOne(id);

    const updateData: any = {};

    if (dto.name) {
      updateData.name = dto.name;
      if (!dto.slug) {
        updateData.slug = this._generateSlug(dto.name);
      }
    }

    if (dto.slug) {
      updateData.slug = dto.slug.toLowerCase().trim();
    }

    // Duplicate check on rename
    if (updateData.name || updateData.slug) {
      const duplicate = await this.prisma.category.findFirst({
        where: {
          id: { not: id },
          OR: [
            updateData.name ? { name: { equals: updateData.name, mode: 'insensitive' as const } } : {},
            updateData.slug ? { slug: updateData.slug } : {},
          ].filter(o => Object.keys(o).length > 0) as any,
        },
      });

      if (duplicate) {
        throw new ConflictException('Category name or slug already exists');
      }
    }

    if (dto.parentId !== undefined) {
      if (dto.parentId) {
        const parent = await this.prisma.category.findUnique({
          where: { id: dto.parentId },
        });
        if (!parent) {
          throw new NotFoundException('Parent category not found');
        }
        await this._checkCircularReference(id, dto.parentId);
      }
      updateData.parentId = dto.parentId;
    }

    if (dto.description !== undefined) updateData.description = dto.description;
    if (dto.image !== undefined) updateData.image = dto.image;
    if (dto.displayOrder !== undefined) updateData.displayOrder = dto.displayOrder;
    if (dto.status !== undefined) updateData.status = dto.status;

    return this.prisma.category.update({
      where: { id },
      data: updateData,
    });
  }

  async remove(id: string) {
    const category = await this.findOne(id);

    // Business check: active products inside category or subcategories
    const productCount = await this.prisma.product.count({
      where: {
        categoryId: id,
        status: 'ACTIVE' as any,
      },
    });

    if (productCount > 0) {
      throw new BadRequestException('Cannot delete category containing active products');
    }

    // Soft delete: mark timestamp and change status
    return this.prisma.category.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: 'ARCHIVED' as any,
      },
    });
  }

  async restore(id: string) {
    // Find archived one
    const category = await this.prisma.category.findUnique({
      where: { id },
    });

    if (!category || !category.deletedAt) {
      throw new BadRequestException('Category is not deleted or does not exist');
    }

    return this.prisma.category.update({
      where: { id },
      data: {
        deletedAt: null,
        status: 'ACTIVE' as any,
      },
    });
  }

  async updateStatus(id: string, status: 'ACTIVE' | 'INACTIVE' | 'ARCHIVED') {
    await this.findOne(id);
    return this.prisma.category.update({
      where: { id },
      data: { status: status as any },
    });
  }

  async uploadImage(id: string, imageUrl: string) {
    await this.findOne(id);
    return this.prisma.category.update({
      where: { id },
      data: { image: imageUrl },
    });
  }
}
