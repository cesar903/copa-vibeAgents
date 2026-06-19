import { MatchesService } from './matches.service';
import { CreateMatchDto } from './dto/create-match.dto';
import { UpdateMatchDto } from './dto/update-match.dto';
import { MatchQueryDto } from './dto/match-query.dto';
export declare class MatchesController {
    private readonly matchesService;
    constructor(matchesService: MatchesService);
    create(createMatchDto: CreateMatchDto): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeTeam: string;
        awayTeam: string;
        competition: string;
        stadium: string;
        startDate: Date;
        status: import("@prisma/client").$Enums.MatchStatus;
        homeGoals: number | null;
        awayGoals: number | null;
    }>;
    findAll(query: MatchQueryDto): Promise<{
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            homeTeam: string;
            awayTeam: string;
            competition: string;
            stadium: string;
            startDate: Date;
            status: import("@prisma/client").$Enums.MatchStatus;
            homeGoals: number | null;
            awayGoals: number | null;
        }[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    findOne(id: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeTeam: string;
        awayTeam: string;
        competition: string;
        stadium: string;
        startDate: Date;
        status: import("@prisma/client").$Enums.MatchStatus;
        homeGoals: number | null;
        awayGoals: number | null;
    }>;
    update(id: string, updateMatchDto: UpdateMatchDto): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeTeam: string;
        awayTeam: string;
        competition: string;
        stadium: string;
        startDate: Date;
        status: import("@prisma/client").$Enums.MatchStatus;
        homeGoals: number | null;
        awayGoals: number | null;
    }>;
    remove(id: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeTeam: string;
        awayTeam: string;
        competition: string;
        stadium: string;
        startDate: Date;
        status: import("@prisma/client").$Enums.MatchStatus;
        homeGoals: number | null;
        awayGoals: number | null;
    }>;
}
