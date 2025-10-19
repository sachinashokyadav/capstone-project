# ==============================
# Stage 1: Build dependencies
# ==============================
FROM node:14-alpine AS builder

WORKDIR /usr/src/app

# Copy dependency files
COPY package*.json ./

# Install dependencies with compatibility flags
RUN npm install --legacy-peer-deps --no-audit --no-fund

# Copy backend source code
COPY . .

# ==============================
# Stage 2: Create final image
# ==============================
FROM node:14-alpine

WORKDIR /usr/src/app

# Copy app from builder
COPY --from=builder /usr/src/app .

# Expose backend port
EXPOSE 3000

# Run backend
CMD ["node", "index.js"]
