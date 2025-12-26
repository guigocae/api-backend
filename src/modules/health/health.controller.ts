import { Controller, Get } from '@nestjs/common';
import { PrismaService } from '../../shared/prisma/prisma.service';
import { 
  HealthCheckService, 
  PrismaHealthIndicator, 
  HealthCheck 
} from '@nestjs/terminus';

@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private db: PrismaHealthIndicator,
    private prisma: PrismaService,
  ) {}

  @Get()
  live() {
    return { status: 'ok' };
  }

  @Get('ready')
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.db.pingCheck('database', this.prisma),
    ]);
  }
}
