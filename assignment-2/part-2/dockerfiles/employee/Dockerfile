FROM golang:1.19-alpine AS build

WORKDIR /app

# Install git
RUN apk add --no-cache git

# Clone the repository
RUN git clone https://github.com/opstree/OT-Microservices.git .

# Build employee service (Golang) - each service has its own directory
RUN if [ -d "employee" ] && [ -f "employee/go.mod" ]; then \
        cd employee && \
        go mod download && \
        go build -o employee-service . && \
        cp employee-service /app/employee-service; \
    else \
        echo "Employee directory or go.mod not found" && \
        echo "Available directories:" && ls -la && \
        echo "Looking for go.mod files:" && find . -name "go.mod" && \
        exit 1; \
    fi

# Runtime stage
FROM alpine:latest

WORKDIR /app

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates curl

# Copy the binary from build stage
COPY --from=build /app/employee-service /app/employee-service

# Make it executable
RUN chmod +x /app/employee-service

EXPOSE 8082

# Run the Go application
CMD ["/app/employee-service"]
