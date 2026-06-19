"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MatchesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const ranking_service_1 = require("../ranking/ranking.service");
let MatchesService = class MatchesService {
    prisma;
    rankingService;
    constructor(prisma, rankingService) {
        this.prisma = prisma;
        this.rankingService = rankingService;
    }
    async create(createMatchDto) {
        return this.prisma.match.create({
            data: {
                homeTeam: createMatchDto.homeTeam,
                awayTeam: createMatchDto.awayTeam,
                competition: createMatchDto.competition,
                stadium: createMatchDto.stadium,
                startDate: new Date(createMatchDto.startDate),
                status: createMatchDto.status,
                homeGoals: createMatchDto.homeGoals,
                awayGoals: createMatchDto.awayGoals,
            },
        });
    }
    async findAll(query) {
        const { status, competition, date, page = 1, limit = 10 } = query;
        const skip = (page - 1) * limit;
        const where = {};
        if (status) {
            where.status = status;
        }
        if (competition) {
            where.competition = { contains: competition, mode: 'insensitive' };
        }
        if (date) {
            const startOfDay = new Date(date);
            startOfDay.setUTCHours(0, 0, 0, 0);
            const endOfDay = new Date(date);
            endOfDay.setUTCHours(23, 59, 59, 999);
            where.startDate = {
                gte: startOfDay,
                lte: endOfDay,
            };
        }
        const [data, total] = await Promise.all([
            this.prisma.match.findMany({
                where,
                skip,
                take: limit,
                orderBy: { startDate: 'asc' },
            }),
            this.prisma.match.count({ where }),
        ]);
        return {
            data,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }
    async findOne(id) {
        const match = await this.prisma.match.findUnique({
            where: { id },
        });
        if (!match) {
            throw new common_1.NotFoundException(`Match with ID ${id} not found`);
        }
        return match;
    }
    async update(id, updateMatchDto) {
        await this.findOne(id);
        const updateData = {
            ...updateMatchDto,
        };
        if (updateMatchDto.startDate) {
            updateData.startDate = new Date(updateMatchDto.startDate);
        }
        const updatedMatch = await this.prisma.match.update({
            where: { id },
            data: updateData,
        });
        if (updatedMatch.status === 'FINISHED') {
            await this.rankingService.updateRankingsForMatch(id);
        }
        return updatedMatch;
    }
    async remove(id) {
        await this.findOne(id);
        return this.prisma.match.delete({
            where: { id },
        });
    }
};
exports.MatchesService = MatchesService;
exports.MatchesService = MatchesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        ranking_service_1.RankingService])
], MatchesService);
//# sourceMappingURL=matches.service.js.map