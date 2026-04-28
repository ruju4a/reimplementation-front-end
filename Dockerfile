# Multi-stage Vite build. Build with:
#   docker build --build-arg VITE_API_BASE_URL=http://YOUR_IP:3002 .
#
# If builds keep failing on VCL (network, native modules), build assets on your
# Mac and use Dockerfile.prebuilt instead (see .env.example).

FROM node:20-bookworm-slim AS builder

# Some deps (e.g. sass) may compile; Alpine often breaks here — Debian is safer.
RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 make g++ \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./

ENV NODE_ENV=production
# `npm install` is more forgiving than `npm ci` when lockfile/client npm differ.
RUN npm install --no-audit --no-fund

COPY . .

ARG VITE_API_BASE_URL=http://localhost:3002
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

# Large builds on small VCL VMs
ENV NODE_OPTIONS=--max-old-space-size=4096

RUN node node_modules/vite/bin/vite.js build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
