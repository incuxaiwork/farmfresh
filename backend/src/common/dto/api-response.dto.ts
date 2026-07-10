import { ApiProperty } from '@nestjs/swagger';

export class SuccessResponseDto<T> {
  @ApiProperty({ example: true })
  success: boolean = true;

  @ApiProperty({ example: 'Operation completed successfully' })
  message: string;

  data?: T;

  constructor(message: string, data?: T) {
    this.message = message;
    this.data = data;
  }
}

export class ErrorResponseDto {
  @ApiProperty({ example: false })
  success: boolean = false;

  @ApiProperty({ example: 'An error occurred during operation' })
  message: string;

  @ApiProperty({ example: 'Bad Request' })
  error: string;

  @ApiProperty({ example: 400 })
  statusCode: number;

  @ApiProperty({ type: 'object', example: { email: 'invalid email address' }, required: false })
  details?: Record<string, string[]>;

  constructor(message: string, error: string, statusCode: number, details?: Record<string, string[]>) {
    this.message = message;
    this.error = error;
    this.statusCode = statusCode;
    this.details = details;
  }
}
