const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function seed() {
  const products = [
    {
      name: 'corainder',
      url: 'https://images.unsplash.com/photo-1595855759920-86582396756a?auto=format&fit=crop&w=400&q=80',
    },
    {
      name: 'potato',
      url: 'https://images.unsplash.com/photo-1518977676601-b53f82afe5f7?auto=format&fit=crop&w=400&q=80',
    },
    {
      name: 'Basmati Rice',
      url: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=400&q=80',
    },
  ];

  for (const item of products) {
    const p = await prisma.product.findFirst({ where: { name: item.name } });
    if (p) {
      const existing = await prisma.productImage.findFirst({
        where: { productId: p.id },
      });
      if (!existing) {
        await prisma.productImage.create({
          data: {
            productId: p.id,
            imageUrl: item.url,
            isPrimary: true,
          },
        });
        console.log('Added image for ' + item.name + ' (id: ' + p.id + ')');
      } else {
        console.log('Image already exists for ' + item.name);
      }
    } else {
      console.log('Product not found: ' + item.name);
    }
  }

  await prisma.$disconnect();
}

seed();
