# ==============================
# Stage 1: Build dependencies
# ==============================
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copy dependency files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy the rest of the backend source
COPY . .

# ==============================
# Stage 2: Create final lightweight image
# ==============================
FROM node:18-alpine

WORKDIR /usr/src/app

# Copy only the necessary built code and dependencies
COPY --from=builder /usr/src/app /usr/src/app

# Expose backend port (adjust if different)
EXPOSE 3000

# Run backend
CMD ["node", "index.js"]
