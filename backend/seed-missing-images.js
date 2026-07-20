const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const defaultImages = {
  'tomato': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=400&q=80',
  'onion': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=400&q=80',
  'mango': 'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&w=400&q=80',
  'apple': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6fac6?auto=format&fit=crop&w=400&q=80',
  'default': 'https://images.unsplash.com/photo-1597362925123-77861d3fbac7?auto=format&fit=crop&w=400&q=80'
};

async function seed() {
  const products = await prisma.product.findMany({
    include: { images: true }
  });

  let seededCount = 0;
  for (const p of products) {
    if (p.images.length === 0) {
      let img = defaultImages['default'];
      const name = p.name.toLowerCase();
      if (name.includes('tomato')) img = defaultImages['tomato'];
      else if (name.includes('onion')) img = defaultImages['onion'];
      else if (name.includes('mango')) img = defaultImages['mango'];
      else if (name.includes('apple')) img = defaultImages['apple'];
      
      await prisma.productImage.create({
        data: {
          productId: p.id,
          imageUrl: img,
          isPrimary: true
        }
      });
      console.log(`Seeded image for missing product: ${p.name}`);
      seededCount++;
    }
  }
  console.log(`Seeded ${seededCount} products.`);
  await prisma.$disconnect();
}

seed();
