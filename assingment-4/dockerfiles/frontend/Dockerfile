FROM node:16-bullseye-slim AS build

WORKDIR /app

# Install git (explicitly using Bullseye to avoid Buster cache issues)
RUN apt-get update -y && \
    apt-get install git -y && \
    rm -rf /var/lib/apt/lists/*

# Clone the repository (Step 1: Code is cloned during build)
RUN git clone https://github.com/opstree/OT-Microservices.git /tmp/repo

# Copy frontend directory (matching original structure)
RUN cp -r /tmp/repo/frontend /app/

WORKDIR /app/frontend

# Install dependencies and build
RUN npm install
RUN npm run build

# Runtime stage
FROM node:16-bullseye-slim

WORKDIR /app

# Install serve globally using npm (yarn may not be available in slim image)
RUN npm install -g serve

# Copy built frontend from build stage
COPY --from=build /app/frontend/build /app/build

EXPOSE 3000

ENTRYPOINT ["serve", "-s", "build"]