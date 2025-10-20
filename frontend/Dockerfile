FROM ghcr.io/cirruslabs/flutter:latest AS builder

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web


FROM nginx:alpine-slim AS runner

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]