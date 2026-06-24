import { Body, Controller, Get, Patch, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../auth/admin.guard';
import { RoundPaymentsService } from './round-payments.service';
import { UpsertRoundPaymentDto } from './dto/upsert-round-payment.dto';

@ApiTags('round-payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('round-payments')
export class RoundPaymentsController {
  constructor(private readonly service: RoundPaymentsService) {}

  @Get()
  @ApiOperation({ summary: 'List users and payment status for a round' })
  findByRound(@Query('round') round?: string) {
    const parsedRound = Number(round);
    const selectedRound =
      Number.isInteger(parsedRound) && parsedRound > 0 ? parsedRound : 1;

    return this.service.findByRound(selectedRound);
  }

  @Patch()
  @ApiOperation({ summary: 'Mark a user as paid/unpaid for a round' })
  upsert(@Body() dto: UpsertRoundPaymentDto) {
    return this.service.upsert(dto);
  }
}
