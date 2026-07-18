-- Add geographic coordinates for delivery navigation system
-- Safe migration: adds nullable columns, no data destruction

-- FarmerProfile: Add farm GPS coordinates
ALTER TABLE "farmer_profiles" ADD COLUMN "farm_latitude" DECIMAL(10, 8);
ALTER TABLE "farmer_profiles" ADD COLUMN "farm_longitude" DECIMAL(11, 8);

-- Order: Add customer delivery coordinates (snapshot at order time)
ALTER TABLE "orders" ADD COLUMN "customer_latitude" DECIMAL(10, 8);
ALTER TABLE "orders" ADD COLUMN "customer_longitude" DECIMAL(11, 8);
ALTER TABLE "orders" ADD COLUMN "farmer_latitude" DECIMAL(10, 8);
ALTER TABLE "orders" ADD COLUMN "farmer_longitude" DECIMAL(11, 8);

-- UserAddress: Add GPS coordinates
ALTER TABLE "user_addresses" ADD COLUMN "latitude" DECIMAL(10, 8);
ALTER TABLE "user_addresses" ADD COLUMN "longitude" DECIMAL(11, 8);
