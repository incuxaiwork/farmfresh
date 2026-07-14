import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting Database Seeding (Indian Localization)...');

  // Reset database rows in correct dependency order
  await prisma.transaction.deleteMany();
  await prisma.payment.deleteMany();
  await prisma.deliveryAssignment.deleteMany();
  await prisma.orderItem.deleteMany();
  await prisma.order.deleteMany();
  await prisma.cartItem.deleteMany();
  await prisma.cart.deleteMany();
  await prisma.userAddress.deleteMany();
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
      farmName: 'Swarna Bharat Farms',
      farmAddress: 'House No. 12, Main Street, Guntur, Andhra Pradesh',
      kycStatus: 'APPROVED',
      bankAccount: {
        create: {
          bankName: 'State Bank of India',
          accountNumber: '9988112233',
          routingNumber: 'SBIN0001234', // IFSC Code format
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

  const grains = await prisma.category.create({
    data: {
      name: 'Grains & Millets',
      slug: 'grains-millets',
      description: 'Harvested organic grains, wheat, rice, and millets.',
      displayOrder: 3,
      status: 'ACTIVE',
    },
  });

  console.log('✅ Created categories: Fruits, Vegetables, Grains & Millets');

  // 4. Create Indian Products & Inventories
  const tomato = await prisma.product.create({
    data: {
      farmerId: farmerProfile.id,
      categoryId: vegetables.id,
      name: 'Organic Tomato',
      slug: 'organic-tomato',
      description: 'Fresh farm grown organic red tomatoes.',
      shortDescription: 'Fresh farm grown red tomatoes.',
      price: 30.00,
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

  const onion = await prisma.product.create({
    data: {
      farmerId: farmerProfile.id,
      categoryId: vegetables.id,
      name: 'Fresh Red Onion',
      slug: 'fresh-red-onion',
      description: 'Crisp and pungent red onions from Maharashtra fields.',
      shortDescription: 'Maharashtra red onions.',
      price: 40.00,
      unit: '1 kg',
      status: 'APPROVED',
      organic: false,
      featured: true,
      inventory: {
        create: {
          farmerId: farmerProfile.id,
          currentStock: 150,
          minStockLevel: 20,
          maxStockLevel: 1000,
          reorderLevel: 50,
          status: 'IN_STOCK',
        },
      },
    },
  });

  const mango = await prisma.product.create({
    data: {
      farmerId: farmerProfile.id,
      categoryId: fruits.id,
      name: 'Alphonso Mango',
      slug: 'alphonso-mango',
      description: 'Deliciously sweet premium Alphonso mangoes from Devgad orchards.',
      shortDescription: 'Sweet Devgad Alphonso mangoes.',
      price: 150.00,
      unit: '1 kg',
      status: 'APPROVED',
      organic: true,
      featured: true,
      inventory: {
        create: {
          farmerId: farmerProfile.id,
          currentStock: 80,
          minStockLevel: 5,
          maxStockLevel: 200,
          reorderLevel: 15,
          status: 'IN_STOCK',
        },
      },
    },
  });

  const rice = await prisma.product.create({
    data: {
      farmerId: farmerProfile.id,
      categoryId: grains.id,
      name: 'Basmati Rice',
      slug: 'basmati-rice',
      description: 'Long grain aromatic aged Basmati rice from Himalayan fields.',
      shortDescription: 'Aromatically aged Basmati rice.',
      price: 90.00,
      unit: '1 kg',
      status: 'APPROVED',
      organic: true,
      featured: false,
      inventory: {
        create: {
          farmerId: farmerProfile.id,
          currentStock: 200,
          minStockLevel: 25,
          maxStockLevel: 2000,
          reorderLevel: 100,
          status: 'IN_STOCK',
        },
      },
    },
  });

  console.log('✅ Created catalog products: Tomato, Onion, Mango, Basmati Rice');
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
