import { IsNotEmpty, IsString, IsOptional, IsNumber, Min, IsUUID, IsBoolean, IsDateString, IsInt, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProductDto {
  @ApiProperty({ example: 'Organic Fuji Apples', description: 'Product title' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(150)
  name: string;

  @ApiProperty({ example: 'organic-fuji-apples', description: 'Unique slug override. Auto-generated if omitted.', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(170)
  slug?: string;

  @ApiProperty({ example: 'Crunchy sweet orchard fresh apples.', description: 'Detailed product description' })
  @IsNotEmpty()
  @IsString()
  description: string;

  @ApiProperty({ example: 'Sweet orchard fresh apples.', description: 'Short summary text description', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  shortDescription?: string;

  @ApiProperty({ example: 'uuid-category-apples', description: 'Category identifier' })
  @IsNotEmpty()
  @IsUUID()
  categoryId: string;

  @ApiProperty({ example: 'uuid-sub-category-red-apples', description: 'Sub category identifier', required: false })
  @IsOptional()
  @IsUUID()
  subCategoryId?: string;

  @ApiProperty({ example: 4.99, description: 'Product base price' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0.01, { message: 'Price must be greater than zero' })
  price: number;

  @ApiProperty({ example: 3.99, description: 'Discount price. Must be lower than price.', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0.00)
  discountPrice?: number;

  @ApiProperty({ example: '1 kg', description: 'Unit quantity descriptor' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(50)
  unit: string;

  @ApiProperty({ example: 1, description: 'Minimum check-out volume limit', default: 1, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  minOrderQty?: number;

  @ApiProperty({ example: 10, description: 'Maximum check-out volume limit', default: 10, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  maxOrderQty?: number;

  @ApiProperty({ example: true, description: 'Is the harvest organic?', default: false, required: false })
  @IsOptional()
  @IsBoolean()
  organic?: boolean;

  @ApiProperty({ example: false, description: 'Should this product appear in banners?', default: false, required: false })
  @IsOptional()
  @IsBoolean()
  featured?: boolean;

  @ApiProperty({ example: true, description: 'Is it a seasonal harvest crop?', default: false, required: false })
  @IsOptional()
  @IsBoolean()
  seasonal?: boolean;

  @ApiProperty({ example: '2026-07-09T00:00:00Z', description: 'Harvest timestamp date', required: false })
  @IsOptional()
  @IsDateString()
  harvestDate?: string;

  @ApiProperty({ example: '2026-07-30T00:00:00Z', description: 'Expiry timestamp date', required: false })
  @IsOptional()
  @IsDateString()
  expiryDate?: string;

  @ApiProperty({ example: 50, description: 'Available stock quantity' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0, { message: 'Stock must be non-negative' })
  stock: number;
}
