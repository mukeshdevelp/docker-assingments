FROM python:3.9-slim AS build

WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/opstree/OT-Microservices.git .

# Runtime stage
FROM python:3.9-slim

WORKDIR /app

# Copy attendance service directory
COPY --from=build /app/attendance /app

# Install Python dependencies
RUN if [ -f "requirements.txt" ]; then \
        pip install --no-cache-dir -r requirements.txt; \
    else \
        echo "requirements.txt not found" && exit 1; \
    fi

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

EXPOSE 8081

# Find and run the main Python file
RUN MAIN_FILE=$(find . -maxdepth 1 -name "*.py" | head -1) && \
    if [ -z "$MAIN_FILE" ]; then \
        echo "No Python file found in attendance directory" && exit 1; \
    fi

# Create startup script
RUN echo '#!/bin/sh\n\
MAIN_FILE=$(find . -maxdepth 1 -name "*.py" | head -1)\n\
if [ -n "$MAIN_FILE" ]; then\n\
    echo "Starting: $MAIN_FILE"\n\
    python "$MAIN_FILE" --host=0.0.0.0 --port=8081 || python "$MAIN_FILE"\n\
elif [ -f "app.py" ]; then\n\
    python app.py --host=0.0.0.0 --port=8081\n\
elif [ -f "main.py" ]; then\n\
    python main.py --host=0.0.0.0 --port=8081\n\
else\n\
    echo "No main Python file found" && exit 1\n\
fi' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
