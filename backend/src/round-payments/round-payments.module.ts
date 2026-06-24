import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { RankingModule } from '../ranking/ranking.module';
import { AdminGuard } from '../auth/admin.guard';
import { RoundPaymentsController } from './round-payments.controller';
import { RoundPaymentsService } from './round-payments.service';

@Module({
  imports: [PrismaModule, RankingModule],
  controllers: [RoundPaymentsController],
  providers: [RoundPaymentsService, AdminGuard],
})
export class RoundPaymentsModule {}
