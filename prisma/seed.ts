import { PrismaClient } from "../src/generated/prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

async function main() {
  // 1) Roles
  const roles = ["MASTER", "ADMIN", "TECHNICIAN", "LOGISTICS"] as const;
  for (const key of roles) {
    await prisma.role.upsert({
      where: { key },
      update: {},
      create: { key },
    });
  }

  //2) Bootstrap MASTER
  const masterClerkUserId = process.env.MASTER_CLERK_USER_ID;
  if(!masterClerkUserId) {
    console.warn("MASTER_CLERK_USER_ID não definido. Seed  criou roles, mas não criou MASTER.");
    return;
  }

  const user = await prisma.user.upsert({
    where: { clerkUserId: masterClerkUserId },
    update: {},
    create: { clerkUserId: masterClerkUserId },
  });

  const masterRole = await prisma.role.findUniqueOrThrow({ where: { key: "MASTER" } });
  await prisma.userRole.upsert({
    where: { userId_roleId: { userId: user.id, roleId: masterRole.id } },
    update: {},
    create: { userId: user.id, roleId: masterRole.id },
  });
}

main()
  .finally(async () => prisma.$disconnect())
  .catch(async (e) => {
    console.log(e);
    await prisma.$disconnect();
    process.exit(1);
  });