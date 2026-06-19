import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import type { User } from '@prisma/client';
import { AdminGuard } from './admin.guard';

describe('AdminGuard', () => {
  const guard = new AdminGuard();

  function contextFor(email?: string): ExecutionContext {
    const user = email ? ({ email } as User) : undefined;
    return {
      switchToHttp: () => ({ getRequest: () => ({ user }) }),
    } as ExecutionContext;
  }

  it('allows the configured administrator', () => {
    expect(guard.canActivate(contextFor('cesarreis521@gmail.com'))).toBe(true);
  });

  it('rejects another authenticated user', () => {
    expect(() => guard.canActivate(contextFor('user@example.com'))).toThrow(
      ForbiddenException,
    );
  });
});
