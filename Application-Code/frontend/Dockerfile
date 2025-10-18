# ==============================
# Stage 1: Build frontend
# ==============================
FROM node:18-alpine AS build

WORKDIR /usr/src/app

# Copy dependency files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all frontend source code and build it
COPY . .
RUN npm run build

# ==============================
# Stage 2: Serve with Nginx
# ==============================
FROM nginx:alpine

# Copy build output to Nginx’s HTML directory
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# Expose default Nginx port
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
