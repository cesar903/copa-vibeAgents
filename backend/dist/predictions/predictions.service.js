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
exports.PredictionsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let PredictionsService = class PredictionsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    checkTimeLimit(startDate) {
        const limitTime = new Date(startDate.getTime() - 15 * 60 * 1000);
        if (new Date() >= limitTime) {
            throw new common_1.ForbiddenException('O prazo para criação ou edição de palpites desta partida foi encerrado.');
        }
    }
    async createOrUpdate(userId, createPredictionDto) {
        const match = await this.prisma.match.findUnique({
            where: { id: createPredictionDto.matchId },
        });
        if (!match) {
            throw new common_1.NotFoundException('Partida não encontrada.');
        }
        this.checkTimeLimit(match.startDate);
        return this.prisma.prediction.upsert({
            where: {
                userId_matchId: {
                    userId,
                    matchId: createPredictionDto.matchId,
                },
            },
            update: {
                homeGoals: createPredictionDto.homeGoals,
                awayGoals: createPredictionDto.awayGoals,
            },
            create: {
                userId,
                matchId: createPredictionDto.matchId,
                homeGoals: createPredictionDto.homeGoals,
                awayGoals: createPredictionDto.awayGoals,
            },
        });
    }
    async findAllByUser(userId) {
        return this.prisma.prediction.findMany({
            where: { userId },
            include: {
                match: true,
            },
            orderBy: {
                match: { startDate: 'asc' },
            },
        });
    }
    async findByMatch(currentUserId, matchId) {
        const match = await this.prisma.match.findUnique({
            where: { id: matchId },
        });
        if (!match) {
            throw new common_1.NotFoundException('Partida não encontrada.');
        }
        const predictions = await this.prisma.prediction.findMany({
            where: { matchId },
            include: { user: { select: { id: true, name: true, avatar: true } } },
        });
        const hasStarted = new Date() >= match.startDate || match.status !== 'SCHEDULED';
        if (!hasStarted) {
            return predictions.filter((p) => p.userId === currentUserId);
        }
        return predictions;
    }
    async findOne(userId, id) {
        const prediction = await this.prisma.prediction.findUnique({
            where: { id },
            include: { match: true },
        });
        if (!prediction) {
            throw new common_1.NotFoundException('Palpite não encontrado.');
        }
        const hasStarted = new Date() >= prediction.match.startDate ||
            prediction.match.status !== 'SCHEDULED';
        if (prediction.userId !== userId && !hasStarted) {
            throw new common_1.ForbiddenException('Você não pode visualizar este palpite antes do início da partida.');
        }
        return prediction;
    }
    async update(userId, id, updatePredictionDto) {
        const prediction = await this.prisma.prediction.findUnique({
            where: { id },
            include: { match: true },
        });
        if (!prediction) {
            throw new common_1.NotFoundException('Palpite não encontrado.');
        }
        if (prediction.userId !== userId) {
            throw new common_1.ForbiddenException('Você não tem permissão para editar este palpite.');
        }
        this.checkTimeLimit(prediction.match.startDate);
        return this.prisma.prediction.update({
            where: { id },
            data: updatePredictionDto,
        });
    }
    async remove(userId, id) {
        const prediction = await this.prisma.prediction.findUnique({
            where: { id },
            include: { match: true },
        });
        if (!prediction) {
            throw new common_1.NotFoundException('Palpite não encontrado.');
        }
        if (prediction.userId !== userId) {
            throw new common_1.ForbiddenException('Você não tem permissão para remover este palpite.');
        }
        this.checkTimeLimit(prediction.match.startDate);
        return this.prisma.prediction.delete({
            where: { id },
        });
    }
};
exports.PredictionsService = PredictionsService;
exports.PredictionsService = PredictionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], PredictionsService);
//# sourceMappingURL=predictions.service.js.map