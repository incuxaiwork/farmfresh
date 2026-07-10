import { Injectable, NestInterceptor, ArgumentsHost, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { SuccessResponseDto } from '../dto/api-response.dto';

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, SuccessResponseDto<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<SuccessResponseDto<T>> {
    return next.handle().pipe(
      map(data => {
        // If data is already an envelope, return directly
        if (data && typeof data === 'object' && 'success' in data && 'message' in data) {
          return data;
        }
        return new SuccessResponseDto('Operation completed successfully', data);
      }),
    );
  }
}
