# ==============================
# Stage 1: Build dependencies
# ==============================
FROM node:16-alpine AS builder

WORKDIR /usr/src/app

# Use npm 8 to handle old package-lock.json
RUN npm install -g npm@8

# Copy dependency files and install production dependencies
COPY package*.json ./
RUN npm ci --only=production --legacy-peer-deps --cache /usr/src/app/.npm-cache

# Copy backend source code
COPY . .

# ==============================
# Stage 2: Create final lightweight image
# ==============================
FROM node:16-alpine

WORKDIR /usr/src/app

# Copy built app from builder
COPY --from=builder /usr/src/app /usr/src/app

# Expose backend port
EXPOSE 3000

# Run backend
CMD ["node", "index.js"]
