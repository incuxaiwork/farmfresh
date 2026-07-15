# Production Node.js Docker Image Build File
FROM node:20-slim AS builder

WORKDIR /usr/src/app

# Install openssl for Prisma engine detection during build
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci

COPY . .

RUN npm run build

# Generate Prisma client using the locally installed version (pinned via package.json)
RUN ./node_modules/.bin/prisma generate

# Final runner container stage
FROM node:20-slim

WORKDIR /usr/src/app

# Install openssl for Prisma runtime
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./

# Install ALL dependencies (including devDependencies) so prisma CLI is available
RUN npm ci

COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /usr/src/app/node_modules/@prisma/client ./node_modules/@prisma/client
COPY --from=builder /usr/src/app/prisma ./prisma

EXPOSE 3000

# Use local prisma binary (always available since we run full npm ci)
CMD ["sh", "-c", "./node_modules/.bin/prisma migrate deploy && node dist/src/main"]
