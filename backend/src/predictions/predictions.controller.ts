import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { PredictionsService } from './predictions.service';
import { CreatePredictionDto } from './dto/create-prediction.dto';
import { UpdatePredictionDto } from './dto/update-prediction.dto';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { User } from '@prisma/client';

@ApiTags('predictions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('predictions')
export class PredictionsController {
  constructor(private readonly predictionsService: PredictionsService) {}

  @Post()
  @ApiOperation({ summary: 'Create or update a prediction (upsert)' })
  @ApiResponse({ status: 201, description: 'Prediction created/updated.' })
  @ApiResponse({
    status: 403,
    description: 'Time limit to predict has expired.',
  })
  create(
    @CurrentUser() user: User,
    @Body() createPredictionDto: CreatePredictionDto,
  ) {
    return this.predictionsService.createOrUpdate(user.id, createPredictionDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all predictions of the current logged user' })
  @ApiResponse({ status: 200, description: 'List of predictions.' })
  findAllByUser(@CurrentUser() user: User) {
    return this.predictionsService.findAllByUser(user.id);
  }

  @Get('match/:matchId')
  @ApiOperation({ summary: 'Get all predictions for a specific match' })
  @ApiResponse({
    status: 200,
    description: 'List of predictions. Hide others if match has not started.',
  })
  findByMatch(@CurrentUser() user: User, @Param('matchId') matchId: string) {
    return this.predictionsService.findByMatch(user.id, matchId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a specific prediction by ID' })
  @ApiResponse({ status: 200, description: 'Return prediction if visible.' })
  @ApiResponse({
    status: 403,
    description: 'Forbidden to see others prediction before match starts.',
  })
  findOne(@CurrentUser() user: User, @Param('id') id: string) {
    return this.predictionsService.findOne(user.id, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a prediction' })
  @ApiResponse({ status: 200, description: 'Prediction updated.' })
  @ApiResponse({
    status: 403,
    description: 'Time limit to predict has expired.',
  })
  update(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() updatePredictionDto: UpdatePredictionDto,
  ) {
    return this.predictionsService.update(user.id, id, updatePredictionDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a prediction' })
  @ApiResponse({ status: 200, description: 'Prediction deleted.' })
  @ApiResponse({
    status: 403,
    description: 'Time limit to predict has expired.',
  })
  remove(@CurrentUser() user: User, @Param('id') id: string) {
    return this.predictionsService.remove(user.id, id);
  }
}
