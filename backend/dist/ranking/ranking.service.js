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
exports.RankingService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let RankingService = class RankingService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async calculateRankingForUser(userId) {
        const predictions = await this.prisma.prediction.findMany({
            where: { userId, match: { status: 'FINISHED' } },
            include: { match: true },
        });
        let totalPoints = 0;
        let totalExactScores = 0;
        let totalCorrectWinners = 0;
        for (const pred of predictions) {
            if (pred.match.homeGoals == null || pred.match.awayGoals == null)
                continue;
            const matchHome = pred.match.homeGoals;
            const matchAway = pred.match.awayGoals;
            const isExact = pred.homeGoals === matchHome && pred.awayGoals === matchAway;
            const isCorrectOutcome = Math.sign(matchHome - matchAway) ===
                Math.sign(pred.homeGoals - pred.awayGoals);
            if (isExact) {
                totalPoints += 10;
                totalExactScores += 1;
                totalCorrectWinners += 1;
            }
            else {
                if (isCorrectOutcome) {
                    totalPoints += 5;
                    totalCorrectWinners += 1;
                }
                if (pred.homeGoals === matchHome) {
                    totalPoints += 2;
                }
                if (pred.awayGoals === matchAway) {
                    totalPoints += 2;
                }
            }
        }
        await this.prisma.ranking.upsert({
            where: { userId },
            update: {
                points: totalPoints,
                exactScores: totalExactScores,
                correctWinners: totalCorrectWinners,
            },
            create: {
                userId,
                points: totalPoints,
                exactScores: totalExactScores,
                correctWinners: totalCorrectWinners,
                position: 0,
            },
        });
    }
    async updateRankingsForMatch(matchId) {
        const predictions = await this.prisma.prediction.findMany({
            where: { matchId },
            select: { userId: true },
        });
        for (const pred of predictions) {
            await this.calculateRankingForUser(pred.userId);
        }
        await this.refreshGlobalRankingPositions();
    }
    async refreshGlobalRankingPositions() {
        const rankings = await this.prisma.ranking.findMany({
            include: { user: { select: { createdAt: true } } },
        });
        rankings.sort((a, b) => {
            if (b.points !== a.points)
                return b.points - a.points;
            if (b.exactScores !== a.exactScores)
                return b.exactScores - a.exactScores;
            if (b.correctWinners !== a.correctWinners)
                return b.correctWinners - a.correctWinners;
            return a.user.createdAt.getTime() - b.user.createdAt.getTime();
        });
        for (let i = 0; i < rankings.length; i++) {
            const position = i + 1;
            if (rankings[i].position !== position) {
                await this.prisma.ranking.update({
                    where: { id: rankings[i].id },
                    data: { position },
                });
            }
        }
    }
    async findAll(query = {}) {
        const page = query.page ?? 1;
        const limit = query.limit ?? 10;
        const skip = (page - 1) * limit;
        const [data, total] = await Promise.all([
            this.prisma.ranking.findMany({
                skip,
                take: limit,
                orderBy: { position: 'asc' },
                include: {
                    user: {
                        select: { id: true, name: true, avatar: true },
                    },
                },
            }),
            this.prisma.ranking.count(),
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
    async findOne(userId) {
        return this.prisma.ranking.findUnique({
            where: { userId },
            include: {
                user: {
                    select: { id: true, name: true, avatar: true },
                },
            },
        });
    }
};
exports.RankingService = RankingService;
exports.RankingService = RankingService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], RankingService);
//# sourceMappingURL=ranking.service.js.map