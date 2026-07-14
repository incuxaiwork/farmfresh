const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

async function main() {
  const prisma = new PrismaClient();
  
  const email = 'admin@farmfresh.com';
  const password = 'Admin@123';
  
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    console.log('Admin user already exists:');
    console.log('Email: admin@farmfresh.com');
    console.log('Password: Admin@123');
    await prisma.$disconnect();
    return;
  }

  const passwordHash = await bcrypt.hash(password, 12);
  
  const admin = await prisma.user.create({
    data: {
      name: 'Super Admin',
      email,
      passwordHash,
      role: 'ADMIN',
    },
  });

  console.log('Admin user created successfully!');
  console.log('Email: admin@farmfresh.com');
  console.log('Password: Admin@123');
  console.log('User ID:', admin.id);
  
  await prisma.$disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
