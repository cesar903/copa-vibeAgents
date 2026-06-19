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
exports.CreateMatchDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const client_1 = require("@prisma/client");
class CreateMatchDto {
    homeTeam;
    awayTeam;
    competition;
    stadium;
    startDate;
    status;
    homeGoals;
    awayGoals;
}
exports.CreateMatchDto = CreateMatchDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Brazil' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateMatchDto.prototype, "homeTeam", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Argentina' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateMatchDto.prototype, "awayTeam", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'World Cup 2026' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateMatchDto.prototype, "competition", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Maracanã' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateMatchDto.prototype, "stadium", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: '2026-06-16T16:00:00Z' }),
    (0, class_validator_1.IsDateString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateMatchDto.prototype, "startDate", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ enum: client_1.MatchStatus, default: client_1.MatchStatus.SCHEDULED }),
    (0, class_validator_1.IsEnum)(client_1.MatchStatus),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateMatchDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 2 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreateMatchDto.prototype, "homeGoals", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 1 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreateMatchDto.prototype, "awayGoals", void 0);
//# sourceMappingURL=create-match.dto.js.map