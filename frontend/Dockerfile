FROM ghcr.io/cirruslabs/flutter:latest AS builder

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web


FROM registry.access.redhat.com/hi/nginx:1.30

COPY --chown=nginx:nginx --from=builder /app/build/web /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
