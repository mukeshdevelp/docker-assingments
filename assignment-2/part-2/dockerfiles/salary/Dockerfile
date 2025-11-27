FROM maven:3.8-openjdk-11 AS build

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/opstree/OT-Microservices.git .

# Build Salary service (Java) - each service has its own directory
WORKDIR /app
RUN if [ -d "salary" ] && [ -f "salary/pom.xml" ]; then \
        cd salary && \
        mvn clean package -DskipTests && \
        find target -name "*.jar" ! -name "*sources.jar" ! -name "*javadoc.jar" -exec cp {} /app/salary.jar \; ; \
    else \
        echo "Salary directory or pom.xml not found" && \
        echo "Available directories:" && ls -la && \
        echo "Looking for pom.xml files:" && find . -name "pom.xml" && \
        exit 1; \
    fi

# Runtime stage
FROM eclipse-temurin:11-jre

WORKDIR /app

# Copy the built JAR from standard location
COPY --from=build /app/salary.jar app.jar

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

EXPOSE 8083

ENTRYPOINT ["java", "-jar", "app.jar"]
