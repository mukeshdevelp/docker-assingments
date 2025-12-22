FROM python:3.9-slim AS build

WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the repository (Step 1: Code is cloned during build)
RUN git clone https://github.com/opstree/OT-Microservices.git /tmp/repo

# Copy attendance service (matching original structure)
RUN cp -r /tmp/repo/attendance /app/

# Runtime stage
FROM python:3.9-slim

WORKDIR /app

# Copy attendance service from build stage
COPY --from=build /app/attendance /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create config directory and copy config.yaml (matching original Dockerfile structure)
# Update config.yaml with correct MySQL values to match docker-compose.yml
# Original config has: host: "172.17.0.6", db_name: "attendance_db", username: root, password: password
RUN mkdir -p /app/config && \
    cp /app/config.yaml /app/config/config.yaml && \
    sed -i 's/host: "172.17.0.6"/host: "mysql"/' /app/config/config.yaml && \
    sed -i 's/db_name: "attendance_db"/db_name: "otmicroservices"/' /app/config/config.yaml && \
    sed -i 's/username: root/username: otuser/' /app/config/config.yaml && \
    sed -i 's/password: password/password: otpassword/' /app/config/config.yaml

EXPOSE 8081

# Set environment variable for config file location
ENV CONFIG_FILE="/app/config/config.yaml"

# Use gunicorn to run attendance_api.py (matching original Dockerfile)
# Increased timeout to prevent worker timeouts during health checks
# Using 180 seconds timeout and graceful timeout to handle slow MySQL connections
ENTRYPOINT ["gunicorn"]
CMD ["--bind", "0.0.0.0:8081", "--timeout", "180", "--graceful-timeout", "180", "--workers", "2", "--worker-class", "sync", "--worker-connections", "1000", "attendance_api:app"]