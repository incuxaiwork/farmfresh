// Migration to create user_profiles table for additional user profile information
// This table links to the core User model through a one-to-one relationship

migration up() {
   CREATE TABLE user_profiles (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     user_id UUID NOT NULL UNIQUE,
     avatar_url TEXT,
     bio TEXT,
     date_of_birth DATE,
     gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
     FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
   );

   CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
}

migration down() {
   DROP TABLE IF EXISTS user_profiles;
}