# FarmFresh API Backend Foundation

This directory houses the NestJS microservice core backend foundation for the FarmFresh multi-vendor marketplace.

---

## 🛠️ Stack & Services
* **NestJS**: Modular Enterprise TypeScript Framework.
* **Prisma ORM**: Type-safe client queries.
* **PostgreSQL**: Primary transactional database.
* **Redis**: Fast cache key mappings and throttler rate counters.
* **Swagger**: Auto-compiled API interface testing portal.

---

## 📁 Architecture Layout
* `src/config/`: Application environment profile bindings and runtime validations (`Joi`).
* `src/database/`: Unified database connectivity wrappers (`PrismaService`).
* `src/common/`: Shared response schemas, guards (`RolesGuard`), custom decorators (`@CurrentUser`), interceptors, and exception parsers.
* `src/auth/`: Core authentication token validation strategies (`PassportJwt`, `JwtRefreshStrategy`).

---

## 🚀 Setup & Execution Guide

### 1. Provision Infrastructure Containers
Spin up the local PostgreSQL and Redis servers:
```bash
docker-compose up -d
```

### 2. Configure Environment variables
Copy variables template and enter your configuration tokens:
```bash
cp .env.example .env
```

### 3. Fetch Dependencies & Prepare Database Client
Download NPM assets and generate the type-safe Prisma code client:
```bash
npm install
npx prisma generate
```

### 4. Boot Dev Server
Start the hot-reload NestJS development node:
```bash
npm run start:dev
```
Access the Swagger interactive schema console at:
👉 **[http://localhost:3000/api/docs](http://localhost:3000/api/docs)**
