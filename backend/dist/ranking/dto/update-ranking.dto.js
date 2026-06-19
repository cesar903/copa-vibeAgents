"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateRankingDto = void 0;
const mapped_types_1 = require("@nestjs/mapped-types");
const create_ranking_dto_1 = require("./create-ranking.dto");
class UpdateRankingDto extends (0, mapped_types_1.PartialType)(create_ranking_dto_1.CreateRankingDto) {
}
exports.UpdateRankingDto = UpdateRankingDto;
//# sourceMappingURL=update-ranking.dto.js.map