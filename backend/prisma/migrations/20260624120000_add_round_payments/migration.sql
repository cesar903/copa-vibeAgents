ALTER TABLE "Match" ADD COLUMN "round" INTEGER NOT NULL DEFAULT 1;

CREATE TABLE "RoundPayment" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "round" INTEGER NOT NULL,
    "paid" BOOLEAN NOT NULL DEFAULT false,
    "paidAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RoundPayment_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "RoundPayment_userId_round_key" ON "RoundPayment"("userId", "round");
CREATE INDEX "RoundPayment_round_idx" ON "RoundPayment"("round");

ALTER TABLE "RoundPayment" ADD CONSTRAINT "RoundPayment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
