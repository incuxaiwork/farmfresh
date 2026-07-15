# Stage 1: Build the Flutter Web application
FROM ghcr.io/cirruslabs/flutter:3.22.3 AS builder

WORKDIR /app

# Copy pubspec files and fetch dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy all source code including the web/ directory
COPY . .

# Build Flutter Web in release mode pointing to your live Railway API
RUN flutter build web --release \
    --dart-define=API_BASE_URL=https://farmfresh-production-01f2.up.railway.app/api/v1 \
    --dart-define=SOCKET_BASE_URL=https://farmfresh-production-01f2.up.railway.app

# Stage 2: Serve using Nginx
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
