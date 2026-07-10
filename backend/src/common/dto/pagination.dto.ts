import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsInt, Min, Max, IsString } from 'class-validator';
import { Type } from 'class-transformer';

export class KeysetPaginationDto {
  @ApiProperty({ description: 'Cursor ID for key-based pagination paging. Omit for page 1.', required: false })
  @IsOptional()
  @IsString()
  cursor?: string;

  @ApiProperty({ description: 'Number of rows to retrieve per request', default: 15, required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit: number = 15;
}
