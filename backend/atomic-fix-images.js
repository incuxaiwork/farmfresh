const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const mapping = {
  'Alphonso Mango': 'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?w=400',
  'Ooty Tomatoes Special': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400',
  'Fresh Test Apple': 'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?w=400'
};

async function fixBrokenImages() {
  const products = await prisma.product.findMany({
    where: { name: { in: Object.keys(mapping) } },
    include: { images: true }
  });

  const updates = [];

  for (const product of products) {
    const newUrl = mapping[product.name];
    if (product.images.length > 0) {
      // Find the primary image or just the first one
      const primaryImage = product.images.find(img => img.isPrimary) || product.images[0];
      
      updates.push(
        prisma.productImage.update({
          where: { id: primaryImage.id },
          data: { imageUrl: newUrl }
        })
      );
    }
  }

  if (updates.length > 0) {
    console.log(`Executing ${updates.length} updates in a single transaction...`);
    await prisma.$transaction(updates);
    console.log("Transaction complete.");
  } else {
    console.log("No matching images found to update.");
  }

  await prisma.$disconnect();
}

fixBrokenImages();
