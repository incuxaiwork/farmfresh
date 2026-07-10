import { IsNotEmpty, IsString, IsOptional, IsInt, IsUUID, IsEnum, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCategoryDto {
  @ApiProperty({ example: 'Leafy Vegetables', description: 'Unique category name' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiProperty({ example: 'leafy-vegetables', description: 'Unique slug. Auto-generated from name if omitted.', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  slug?: string;

  @ApiProperty({ example: 'Fresh green leafy crop harvests.', description: 'Brief category description', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ example: 'https://images.unsplash.com/spinach', description: 'Category image URL', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  image?: string;

  @ApiProperty({ example: 1, description: 'Display order priority index', default: 0, required: false })
  @IsOptional()
  @IsInt()
  displayOrder?: number;

  @ApiProperty({ example: 'uuid-parent-category', description: 'Parent category ID for sub-categorization', required: false })
  @IsOptional()
  @IsUUID()
  parentId?: string;

  @ApiProperty({ example: 'ACTIVE', enum: ['ACTIVE', 'INACTIVE', 'ARCHIVED'], default: 'ACTIVE', required: false })
  @IsOptional()
  @IsEnum(['ACTIVE', 'INACTIVE', 'ARCHIVED'])
  status?: 'ACTIVE' | 'INACTIVE' | 'ARCHIVED';
}
