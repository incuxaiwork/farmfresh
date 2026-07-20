import { IsString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ProfileImageUploadDto {
  @ApiProperty({ example: 'https://example.com/old-image.jpg', description: 'Existing profile image URL', required: false })
  @IsOptional()
  @IsString()
  oldImageUrl?: string;
}
