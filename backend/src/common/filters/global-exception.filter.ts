import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus } from '@nestjs/common';
import { Response } from 'express';
import { Prisma } from '@prisma/client';
import { ErrorResponseDto } from '../dto/api-response.dto';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'An unexpected server error occurred';
    let error = 'Internal Server Error';
    let details: Record<string, string[]> | undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const resBody = exception.getResponse();
      
      if (typeof resBody === 'object' && resBody !== null) {
        const bodyObj = resBody as Record<string, unknown>;
        message = (bodyObj.message as string) || exception.message;
        error = (bodyObj.error as string) || exception.name;
        if (bodyObj.message && Array.isArray(bodyObj.message)) {
          message = 'Validation failed';
          details = { validation: bodyObj.message as string[] };
        }
      } else {
        message = exception.message;
      }
    } else if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      // Prisma error mapper
      switch (exception.code) {
        case 'P2002':
          status = HttpStatus.CONFLICT;
          message = `Unique constraint failed on fields: ${(exception.meta?.target as string[])?.join(', ')}`;
          error = 'Conflict';
          break;
        case 'P2025':
          status = HttpStatus.NOT_FOUND;
          message = exception.message || 'Record not found';
          error = 'Not Found';
          break;
        default:
          status = HttpStatus.BAD_REQUEST;
          message = exception.message;
          error = 'Prisma Database Error';
          break;
      }
    } else if (exception instanceof Error) {
      message = exception.message;
    }

    const payload = new ErrorResponseDto(message, error, status, details);
    response.status(status).json(payload);
  }
}
