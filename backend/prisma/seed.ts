import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting Database Seeding...');

  // Reset database rows
  await prisma.inventoryHistory.deleteMany();
  await prisma.inventory.deleteMany();
  await prisma.productImage.deleteMany();
  await prisma.product.deleteMany();
  await prisma.category.deleteMany();
  await prisma.bankAccount.deleteMany();
  await prisma.farmerProfile.deleteMany();
  await prisma.refreshToken.deleteMany();
  await prisma.user.deleteMany();

  const passwordHash = await bcrypt.hash('password123', 12);

  // 1. Create Users
  const customer = await prisma.user.create({
    data: {
      name: 'Jane Customer',
      email: 'customer@farmfresh.com',
      passwordHash,
      role: 'CUSTOMER',
    },
  });

  const farmerUser = await prisma.user.create({
    data: {
      name: 'John Farmer',
      email: 'farmer@farmfresh.com',
      passwordHash,
      role: 'FARMER',
    },
  });

  const deliveryUser = await prisma.user.create({
    data: {
      name: 'Amit Rider',
      email: 'delivery@farmfresh.com',
      passwordHash,
      role: 'DELIVERY_PARTNER',
    },
  });

  console.log('✅ Created default users: Customer, Farmer, Delivery');

  // 2. Create Farmer Profiles
  const farmerProfile = await prisma.farmerProfile.create({
    data: {
      userId: farmerUser.id,
      farmName: 'Organic Green Farms',
      farmAddress: '44 Orchard Valley, NY',
      kycStatus: 'APPROVED',
      bankAccount: {
        create: {
          bankName: 'Federal Bank',
          accountNumber: '9988112233',
          routingNumber: '021000021',
        },
      },
    },
  });

  console.log('✅ Created farmer business profile');

  // 3. Create Categories
  const fruits = await prisma.category.create({
    data: {
      name: 'Fresh Fruits',
      slug: 'fresh-fruits',
      description: 'Orchard fresh harvest crops and seasonal fruits.',
      displayOrder: 1,
      status: 'ACTIVE',
    },
  });

  const vegetables = await prisma.category.create({
    data: {
      name: 'Fresh Vegetables',
      slug: 'fresh-vegetables',
      description: 'Green organic leaves and root vegetables.',
      displayOrder: 2,
      status: 'ACTIVE',
    },
  });

  console.log('✅ Created categories: Fruits, Vegetables');

  // 4. Create Products & Inventories
  const apple = await prisma.product.create({
    data: {
      farmerId: farmerProfile.id,
      categoryId: fruits.id,
      name: 'Fuji Apples',
      slug: 'fuji-apples',
      description: 'Sweet crunchy organic red apples.',
      shortDescription: 'Sweet crunchy red apples.',
      price: 3.99,
      unit: '1 kg',
      status: 'APPROVED',
      organic: true,
      featured: true,
      inventory: {
        create: {
          farmerId: farmerProfile.id,
          currentStock: 100,
          minStockLevel: 10,
          maxStockLevel: 500,
          reorderLevel: 25,
          status: 'IN_STOCK',
        },
      },
    },
  });

  const spinach = await prisma.product.create({
    data: {
      farmerId: farmerProfile.id,
      categoryId: vegetables.id,
      name: 'Organic Spinach',
      slug: 'organic-spinach',
      description: 'Orchard-grown clean green iron-rich spinach leaves.',
      shortDescription: 'Clean green iron-rich spinach.',
      price: 2.49,
      unit: '1 bunch',
      status: 'APPROVED',
      organic: true,
      featured: false,
      inventory: {
        create: {
          farmerId: farmerProfile.id,
          currentStock: 50,
          minStockLevel: 5,
          maxStockLevel: 200,
          reorderLevel: 15,
          status: 'IN_STOCK',
        },
      },
    },
  });

  console.log('✅ Created catalog products: Fuji Apples, Spinach');
  console.log('🌱 Seeding Completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed with error: ', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
