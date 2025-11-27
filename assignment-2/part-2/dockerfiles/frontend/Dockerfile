FROM node:16-alpine AS build

WORKDIR /app

# Install git
RUN apk add --no-cache git

# Clone the repository
RUN git clone https://github.com/opstree/OT-Microservices.git .

# Build Frontend - frontend has package.json
WORKDIR /app/frontend
RUN if [ -f "package.json" ]; then \
        npm install && \
        npm run build; \
    else \
        echo "package.json not found in frontend directory" && exit 1; \
    fi

# Runtime stage - serve with nginx
FROM nginx:alpine

# Copy built frontend
COPY --from=build /app/frontend/build /usr/share/nginx/html

# Copy nginx configuration for frontend
COPY dockerfiles/frontend/nginx-frontend.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]

