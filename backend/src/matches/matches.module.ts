import { Module } from '@nestjs/common';
import { MatchesService } from './matches.service';
import { MatchesController } from './matches.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { RankingModule } from '../ranking/ranking.module';
import { AdminGuard } from '../auth/admin.guard';

@Module({
  imports: [PrismaModule, RankingModule],
  controllers: [MatchesController],
  providers: [MatchesService, AdminGuard],
})
export class MatchesModule {}
