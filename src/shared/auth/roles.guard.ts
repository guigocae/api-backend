import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PrismaService } from '../prisma/prisma.service';
import { ROLES_KEY } from './decorators/roles.decorator';
import { RequestWithAuth } from './auth.types';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const required = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);

    if (!required || required.length === 0) return true;

    const req = ctx.switchToHttp().getRequest<RequestWithAuth>();
    const clerkUserId = req.auth?.clerkUserId;
    if (!clerkUserId) return false;

    const user = await this.prisma.user.findUnique({
      where: { clerkUserId },
      include: { roles: { include: { role: true } } },
    });

    const userRoles = new Set(user?.roles.map((r) => r.role.key) ?? []);
    const ok = required.some((r) => userRoles.has(r as any));

    if (!ok)
      throw new ForbiddenException('Você não tem permissão para essa ação');
    return true;
  }
}
