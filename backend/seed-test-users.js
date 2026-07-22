const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/eapp?schema=public',
    },
  },
});

async function main() {
  const passwordHash = await bcrypt.hash('password123', 10);

  const usersToEnsure = [
    { email: 'customer@farmfresh.com', name: 'Customer User', role: 'CUSTOMER', phone: '+919999900001' },
    { email: 'farmer@farmfresh.com', name: 'Farmer User', role: 'FARMER', phone: '+919999900002' },
    { email: 'delivery@farmfresh.com', name: 'Delivery Partner', role: 'DELIVERY_PARTNER', phone: '+919999900003' },
    { email: 'admin@farmfresh.com', name: 'Admin User', role: 'ADMIN', phone: '+919999900004' },
  ];

  for (const u of usersToEnsure) {
    let existing = await prisma.user.findUnique({ where: { email: u.email } });
    if (existing) {
      await prisma.user.update({
        where: { id: existing.id },
        data: { passwordHash, role: u.role },
      });
      console.log(`✅ Updated password for ${u.email} -> password123`);
    } else {
      existing = await prisma.user.create({
        data: {
          email: u.email,
          name: u.name,
          role: u.role,
          phone: u.phone,
          passwordHash,
        },
      });
      console.log(`✅ Created test user ${u.email} -> password123`);
    }

    if (u.role === 'FARMER') {
      let fp = await prisma.farmerProfile.findFirst({ where: { userId: existing.id } });
      if (!fp) {
        await prisma.farmerProfile.create({
          data: {
            userId: existing.id,
            farmName: 'Swarna Bharat Organics',
            farmAddress: 'Guntur, Andhra Pradesh',
            kycStatus: 'APPROVED',
          },
        });
      }
    }

    if (u.role === 'DELIVERY_PARTNER') {
      try {
        await prisma.driverProfile.upsert({
          where: { userId: existing.id },
          update: {
            vehicleType: 'BIKE',
            vehicleNumber: 'AP2670983',
            licenseNumber: 'AP16 20210001234',
            bankName: 'boi',
            accountNumber: '256789867890',
            routingNumber: 'BKID000789745',
          },
          create: {
            userId: existing.id,
            vehicleType: 'BIKE',
            vehicleNumber: 'AP2670983',
            licenseNumber: 'AP16 20210001234',
            bankName: 'boi',
            accountNumber: '256789867890',
            routingNumber: 'BKID000789745',
          },
        });
      } catch (err) {
        console.warn('DriverProfile seed error:', err.message);
      }
    }
  }

  const allUsers = await prisma.user.findMany({
    select: { id: true, email: true, role: true }
  });

  console.log('\n--- Registered Users in Database ---');
  console.table(allUsers);

  await prisma.$disconnect();
}

main().catch(err => {
  console.error('Error seeding test users:', err);
  process.exit(1);
});
