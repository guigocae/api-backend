import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { RequestWithAuth } from '../auth.types';

export const CurrentAuth = createParamDecorator((_, ctx: ExecutionContext) => {
  const req = ctx.switchToHttp().getRequest<RequestWithAuth>();
  return req.auth;
});
