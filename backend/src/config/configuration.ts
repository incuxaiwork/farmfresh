export default () => {
  const jwtSecret = process.env.JWT_SECRET;
  const jwtRefreshSecret = process.env.JWT_REFRESH_SECRET;

  if (!jwtSecret || jwtSecret === 'your-super-secret-jwt-access-token-key-min-32-chars') {
    throw new Error('JWT_SECRET environment variable is required and must be a secure random string (min 32 chars). Generate with: openssl rand -base64 32');
  }

  if (!jwtRefreshSecret || jwtRefreshSecret === 'your-super-secret-jwt-refresh-token-key-min-32-chars') {
    throw new Error('JWT_REFRESH_SECRET environment variable is required and must be a secure random string (min 32 chars). Generate with: openssl rand -base64 32');
  }

  return {
    port: parseInt(process.env.PORT || '3000', 10),
    database: {
      url: process.env.DATABASE_URL,
    },
    jwt: {
      secret: jwtSecret,
      expiresIn: process.env.JWT_ACCESS_EXPIRATION || '15m',
      refreshSecret: jwtRefreshSecret,
      refreshExpiresIn: process.env.JWT_REFRESH_EXPIRATION || '7d',
    },
    cloud: {
      cloudName: process.env.CLOUDINARY_CLOUD_NAME,
      apiKey: process.env.CLOUDINARY_API_KEY,
      apiSecret: process.env.CLOUDINARY_API_SECRET,
    },
    rateLimit: {
      ttl: parseInt(process.env.THROTTLE_TTL || '60', 10),
      limit: parseInt(process.env.THROTTLE_LIMIT || '100', 10),
    },
    cors: {
      origins: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3000', 'http://localhost:5173', 'http://localhost:8080'],
    },
    nodeEnv: process.env.NODE_ENV || 'development',
    orders: {
      transitionDelayMs: parseInt(process.env.ORDER_TRANSITION_DELAY_MS || '120000', 10),
    },
  };
}