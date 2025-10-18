# ==============================
# Stage 1: Build dependencies
# ==============================
FROM node:16-alpine AS builder

WORKDIR /usr/src/app

# Copy dependency files and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy the rest of the backend source
COPY . .

# ==============================
# Stage 2: Create final lightweight image
# ==============================
FROM node:16-alpine

WORKDIR /usr/src/app

# Copy only necessary files from builder
COPY --from=builder /usr/src/app /usr/src/app

# Expose backend port
EXPOSE 3000

# Run backend
CMD ["node", "index.js"]
