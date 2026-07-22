const fs = require('fs');
const path = require('path');
try {
  const envPath = path.join(__dirname, '.env');
  if (fs.existsSync(envPath)) {
    const envFile = fs.readFileSync(envPath, 'utf8');
    envFile.split('\n').forEach(line => {
      const match = line.match(/^\s*([^#=]+)\s*=\s*(.*)$/);
      if (match) {
        const key = match[1].trim();
        let val = match[2].trim().replace(/\r$/, '');
        if (val.startsWith('"') && val.endsWith('"')) {
          val = val.substring(1, val.length - 1);
        } else if (val.startsWith("'") && val.endsWith("'")) {
          val = val.substring(1, val.length - 1);
        }
        process.env[key] = val;
      }
    });
  }
  console.log('Loaded DATABASE_URL:', JSON.stringify(process.env.DATABASE_URL));
} catch (e) {
  console.error('Failed to load .env file:', e);
}

const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

async function main() {
  const prisma = new PrismaClient({ datasources: { db: { url: process.env.DATABASE_URL } } });
  
  const email = 'admin@farmfresh.com';
  const password = 'Admin@123';
  
  const passwordHash = await bcrypt.hash(password, 12);

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    await prisma.user.update({
      where: { id: existing.id },
      data: { passwordHash, role: 'ADMIN' },
    });
    console.log('Admin user password updated successfully:');
    console.log('Email: admin@farmfresh.com');
    console.log('Password: Admin@123');
    await prisma.$disconnect();
    return;
  }
  
  const admin = await prisma.user.create({
    data: {
      id: 'a1a868c2-3cf9-42b7-86c0-6bf7a84e20df',
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
