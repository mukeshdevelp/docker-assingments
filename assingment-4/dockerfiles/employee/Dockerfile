FROM golang:1.19-alpine AS build

WORKDIR /app

# Install git
RUN apk add --no-cache git

# Clone the repository (Step 1: Code is cloned during build)
RUN git clone https://github.com/opstree/OT-Microservices.git .

# Build employee service (Golang) - code is now in image
# Binary name should be "employee" (matching original Dockerfile)
RUN if [ -d "employee" ] && [ -f "employee/go.mod" ]; then \
        cd employee && \
        go mod download && \
        go build -o /app/employee-binary . && \
        echo "Binary built successfully"; \
    else \
        echo "Employee directory or go.mod not found" && exit 1; \
    fi

# Runtime stage
FROM alpine:latest

WORKDIR /app

# Install ca-certificates for HTTPS requests, curl for health checks, and libc6-compat (matching original)
RUN apk --no-cache add ca-certificates curl libc6-compat

# Copy the binary from build stage (code is now in image, not needed locally)
COPY --from=build /app/employee-binary /app/employee

# Create config directory (matching original Dockerfile structure)
RUN mkdir -p /root/config

# Copy config.yaml from build stage
COPY --from=build /app/employee/config.yaml /root/config/config.yaml

# Update config.yaml with correct Elasticsearch host to match docker-compose.yml
# Original config has: host: http://empms-es:9200
# Change to: host: http://elasticsearch:9200
RUN sed -i 's|host: http://empms-es:9200|host: http://elasticsearch:9200|' /root/config/config.yaml && \
    sed -i 's/username: elastic/username: ""/' /root/config/config.yaml && \
    sed -i 's/password: elastic/password: ""/' /root/config/config.yaml

# Make it executable
RUN chmod +x /app/employee

EXPOSE 8083

# Set environment variable for config file location
ENV CONFIG_FILE="/root/config/config.yaml"

# Run the Go application (matching original Dockerfile)
ENTRYPOINT ["./employee"]