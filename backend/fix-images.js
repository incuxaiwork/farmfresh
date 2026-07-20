const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const imageMapping = {
  'Alphonso Mango': 'https://upload.wikimedia.org/wikipedia/commons/9/90/Hapus_Mango.jpg',
  'potato': 'https://upload.wikimedia.org/wikipedia/commons/a/ab/Patates.jpg',
  'Organic Tomato': 'https://upload.wikimedia.org/wikipedia/commons/8/89/Tomato_je.jpg',
  'Fresh Red Onion': 'https://upload.wikimedia.org/wikipedia/commons/2/25/Onion_on_White.JPG',
  'Basmati Rice': 'https://upload.wikimedia.org/wikipedia/commons/7/7b/White_rice.jpg',
  'corainder': 'https://upload.wikimedia.org/wikipedia/commons/9/91/Coriander_leaves.jpg',
  'Ooty Tomatoes Special': 'https://upload.wikimedia.org/wikipedia/commons/8/88/Bright_red_tomato_and_cross_section02.jpg',
  'Fresh Test Apple': 'https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg'
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
      console.log(`Updated image for ${p.name}`);
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
  console.log("\n--- Final Image URLs ---");
  finalProducts.forEach(p => {
    const url = p.images.length > 0 ? p.images[0].imageUrl : 'NONE';
    console.log(`${p.name}: ${url}`);
  });

  await prisma.$disconnect();
}

fixImages();
