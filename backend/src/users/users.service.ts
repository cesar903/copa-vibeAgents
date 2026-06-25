import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { RankingService } from '../ranking/ranking.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ChangeUserPasswordDto } from './dto/change-user-password.dto';

const userSelect = {
  id: true,
  name: true,
  email: true,
  avatar: true,
  createdAt: true,
  updatedAt: true,
} as const;

@Injectable()
export class UsersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly rankingService: RankingService,
  ) {}

  async create(createUserDto: CreateUserDto) {
    const existing = await this.prisma.user.findUnique({
      where: { email: createUserDto.email },
      select: { id: true },
    });

    if (existing) {
      throw new ConflictException('E-mail já está em uso.');
    }

    const hashedPassword = await bcrypt.hash(createUserDto.password, 10);

    return this.prisma.user.create({
      data: {
        name: createUserDto.name,
        email: createUserDto.email,
        password: hashedPassword,
        avatar: createUserDto.avatar,
        ranking: { create: { points: 0, position: 0 } },
      },
      select: userSelect,
    });
  }

  findAll() {
    return this.prisma.user.findMany({
      orderBy: { name: 'asc' },
      select: userSelect,
    });
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: userSelect,
    });

    if (!user) {
      throw new NotFoundException('Usuário não encontrado.');
    }

    return user;
  }

  async update(id: string, updateUserDto: UpdateUserDto) {
    await this.findOne(id);

    if (updateUserDto.email) {
      const existing = await this.prisma.user.findUnique({
        where: { email: updateUserDto.email },
        select: { id: true },
      });

      if (existing && existing.id !== id) {
        throw new ConflictException('E-mail já está em uso.');
      }
    }

    return this.prisma.user.update({
      where: { id },
      data: updateUserDto,
      select: userSelect,
    });
  }

  async changePassword(id: string, dto: ChangeUserPasswordDto) {
    await this.findOne(id);

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    return this.prisma.user.update({
      where: { id },
      data: { password: hashedPassword },
      select: userSelect,
    });
  }

  async remove(id: string, currentUserId: string) {
    await this.findOne(id);

    if (id === currentUserId) {
      throw new ForbiddenException(
        'O administrador não pode excluir a própria conta.',
      );
    }

    const deletedUser = await this.prisma.user.delete({
      where: { id },
      select: userSelect,
    });

    await this.rankingService.refreshGlobalRankingPositions();

    return deletedUser;
  }
}
