// Migration to add phone number constraint to users table
// Note: Phone is already unique at the model level in schema.prisma

migration up() {
   ALTER TABLE users
     ADD CONSTRAINT users_phone_unique UNIQUE (phone);
}

migration down() {
   ALTER TABLE users
     DROP CONSTRAINT IF EXISTS users_phone_unique;
}