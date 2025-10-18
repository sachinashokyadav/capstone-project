# ==============================
# Stage 1: Build frontend
# ==============================
FROM node:16-alpine AS build

WORKDIR /usr/src/app

# Use npm 8 to handle old package-lock.json
RUN npm install -g npm@8

# Copy dependency files and install dependencies with legacy-peer-deps
COPY package*.json ./
RUN npm ci --legacy-peer-deps --cache /usr/src/app/.npm-cache

# Copy frontend source code and build
COPY . .
RUN npm run build

# ==============================
# Stage 2: Serve with Nginx
# ==============================
FROM nginx:alpine

# Remove default Nginx HTML
RUN rm -rf /usr/share/nginx/html/*

# Copy build output from previous stage
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# Expose default Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
