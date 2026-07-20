const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const imageMapping = {
  'Organic Tomato': 'https://images.unsplash.com/photo-1597362925123-77861d3fbac7?auto=format&fit=crop&w=400&q=80',
  'corainder': 'https://images.unsplash.com/photo-1595855759920-86582396756a?auto=format&fit=crop&w=400&q=80',
  'Ooty Tomatoes Special': 'https://images.unsplash.com/photo-1518977676601-b53f82afe5f7?auto=format&fit=crop&w=400&q=80',
  'Basmati Rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=400&q=80',
  'potato': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500',
  'Fresh Test Apple': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6fac6?auto=format&fit=crop&w=400&q=80',
  'Alphonso Mango': 'https://images.unsplash.com/photo-1601493700631-281533382921?auto=format&fit=crop&w=400&q=80',
  'Fresh Red Onion': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=400&q=80'
};

async function fixImages() {
  const products = await prisma.product.findMany({
    include: { images: true }
  });

  for (const p of products) {
    const correctUrl = imageMapping[p.name];
    if (!correctUrl) continue;

    if (p.images.length > 0) {
      const primaryImage = p.images.find(img => img.isPrimary) || p.images[0];
      await prisma.productImage.update({
        where: { id: primaryImage.id },
        data: { imageUrl: correctUrl }
      });
      console.log(`Restored image for ${p.name}`);
    } else {
      await prisma.productImage.create({
        data: {
          productId: p.id,
          imageUrl: correctUrl,
          isPrimary: true
        }
      });
      console.log(`Created image for ${p.name}`);
    }
  }

  // Print final list
  const finalProducts = await prisma.product.findMany({
    include: { images: true }
  });
  console.log("\n--- Final Restored Image URLs ---");
  finalProducts.forEach(p => {
    const url = p.images.length > 0 ? p.images[0].imageUrl : 'NONE';
    console.log(`${p.name}: ${url}`);
  });

  await prisma.$disconnect();
}

fixImages();
