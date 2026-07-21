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
} catch (e) {}

const { PrismaClient } = require('@prisma/client');

async function main() {
  const prisma = new PrismaClient({
    datasources: { db: { url: process.env.DATABASE_URL } },
  });
  const products = await prisma.product.findMany({
    include: {
      category: true,
      farmer: { include: { user: true } },
    },
  });

  console.log(`Total Products in Railway DB: ${products.length}`);
  products.forEach(p => {
    console.log(`- ID: ${p.id} | Name: ${p.name} | Status: ${p.status} | Farmer: ${p.farmer?.user?.email || 'N/A'}`);
  });

  const users = await prisma.user.findMany({ select: { id: true, email: true, role: true } });
  console.log('\nUsers in Railway DB:', users);

  await prisma.$disconnect();
}

main().catch(console.error);
