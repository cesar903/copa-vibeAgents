import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
} from '@nestjs/common';
import { MatchesService } from './matches.service';
import { CreateMatchDto } from './dto/create-match.dto';
import { UpdateMatchDto } from './dto/update-match.dto';
import { MatchQueryDto } from './dto/match-query.dto';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../auth/admin.guard';

@ApiTags('matches')
@Controller('matches')
export class MatchesController {
  constructor(private readonly matchesService: MatchesService) {}

  @Post()
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiOperation({ summary: 'Create a new match' })
  @ApiResponse({
    status: 201,
    description: 'The match has been successfully created.',
  })
  create(@Body() createMatchDto: CreateMatchDto) {
    return this.matchesService.create(createMatchDto);
  }

  @Get()
  @ApiOperation({ summary: 'List all matches with pagination and filters' })
  @ApiResponse({ status: 200, description: 'Return paginated matches.' })
  findAll(@Query() query: MatchQueryDto) {
    return this.matchesService.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a match by ID' })
  @ApiResponse({ status: 200, description: 'Return the match.' })
  @ApiResponse({ status: 404, description: 'Match not found.' })
  findOne(@Param('id') id: string) {
    return this.matchesService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiOperation({ summary: 'Update a match' })
  @ApiResponse({
    status: 200,
    description: 'The match has been successfully updated.',
  })
  @ApiResponse({ status: 404, description: 'Match not found.' })
  update(@Param('id') id: string, @Body() updateMatchDto: UpdateMatchDto) {
    return this.matchesService.update(id, updateMatchDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiOperation({ summary: 'Delete a match' })
  @ApiResponse({
    status: 200,
    description: 'The match has been successfully deleted.',
  })
  @ApiResponse({ status: 404, description: 'Match not found.' })
  remove(@Param('id') id: string) {
    return this.matchesService.remove(id);
  }
}
