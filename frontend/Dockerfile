# Stage 1: Build the Flutter Web application
FROM instrumentisto/flutter:3.22.0 AS builder

WORKDIR /app

# Copy configuration and dependencies
COPY pubspec.yaml ./
RUN flutter pub get

# Copy all source code
COPY . .

# Build Flutter Web in release mode pointing to your live Railway API
RUN flutter build web --release --web-renderer html --dart-define=API_BASE_URL=https://farmfresh-production-01f2.up.railway.app/api/v1 --dart-define=SOCKET_BASE_URL=https://farmfresh-production-01f2.up.railway.app

# Stage 2: Serve using Nginx
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
