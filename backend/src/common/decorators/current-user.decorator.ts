import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
// Make typescript compilation happy if role checks or types are used in imports
export interface CurrentUserPayload {
  id: string;
  email: string;
  role: string;
}
