import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AdminGuard } from '../auth/admin.guard';
import { RankingModule } from '../ranking/ranking.module';

@Module({
  imports: [PrismaModule, RankingModule],
  controllers: [UsersController],
  providers: [UsersService, AdminGuard],
})
export class UsersModule {}
