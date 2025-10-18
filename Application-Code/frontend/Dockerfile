# ==============================
# Stage 1: Build frontend
# ==============================
FROM node:16-alpine AS build

WORKDIR /usr/src/app

# Copy dependency files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy frontend source code and build
COPY . .
RUN npm run build

# ==============================
# Stage 2: Serve with Nginx
# ==============================
FROM nginx:alpine

# Remove default Nginx HTML and copy build output
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# Expose default Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
