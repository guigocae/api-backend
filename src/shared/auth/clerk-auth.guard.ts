import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { verifyToken } from '@clerk/backend';
import { IS_PUBLIC_KEY } from './decorators/public.decorator';
import { RequestWithAuth } from './auth.types';

function getBearerToken(req: any): string | null {
  const header = req.headers?.authorization;
  if (typeof header === 'string' && header.startsWith('Bearer ')) {
    return header.slice('Bearer '.length);
  }
  return null;
}

@Injectable()
export class ClerkAuthGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
    if (isPublic) return true;

    const req = ctx.switchToHttp().getRequest<RequestWithAuth>();
    const token = getBearerToken(req);

    if (!token) throw new UnauthorizedException('Missing Clerk session token');

    try {
      const authorizedParties = (process.env.CLERK_AUTHORIZED_PARTIES || '')
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean);

      const verified = await verifyToken(token, {
        jwtKey: process.env.CLERK_JWT_KEY,
        secretKey: process.env.CLERK_SECRET_KEY,
        authorizedParties: authorizedParties.length
          ? authorizedParties
          : undefined,
      });

      if (!verified?.sub) throw new UnauthorizedException('Invalid token');

      req.auth = {
        clerkUserId: verified.sub,
        sessionId: (verified as any).sid,
        azp: (verified as any).azp,
      };

      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired Clerk token');
    }
  }
}
