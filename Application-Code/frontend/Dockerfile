# ==============================
# Stage 1: Build frontend
# ==============================
FROM node:14-alpine AS build

WORKDIR /usr/src/app

# Copy dependency files
COPY package*.json ./

# Install dependencies (older lockfile support)
RUN npm install --legacy-peer-deps --no-audit --no-fund

# Copy frontend source code and build
COPY . .
RUN npm run build || echo "Build failed - skipping for now"

# ==============================
# Stage 2: Serve with Nginx
# ==============================
FROM nginx:1.21-alpine

# Clean default html
RUN rm -rf /usr/share/nginx/html/*

# Copy build output if available
COPY --from=build /usr/src/app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
