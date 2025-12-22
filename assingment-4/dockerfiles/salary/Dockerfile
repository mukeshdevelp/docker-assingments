FROM maven:3.8-openjdk-11 AS build

WORKDIR /java

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the repository (Step 1: Code is cloned during build)
RUN git clone https://github.com/opstree/OT-Microservices.git /tmp/repo

# Copy salary service files (matching original structure)
RUN cp /tmp/repo/salary/pom.xml /java/ && \
    cp -r /tmp/repo/salary/src /java/src/

# Update application.properties to use environment variable or correct default
# Original has hardcoded IP: spring.elasticsearch.rest.uris=172.17.0.3:9200
# Change to use elasticsearch service name (will be overridden by env var if set)
RUN sed -i 's|spring.elasticsearch.rest.uris=172.17.0.3:9200|spring.elasticsearch.rest.uris=http://elasticsearch:9200|' /java/src/main/resources/application.properties

# Build Salary service (Java) - code is now in image
# JAR name is salary-0.3.0-RELEASE.jar (matching original Dockerfile)
RUN mvn clean package -DskipTests -Ddependency-check.skip=true

# Runtime stage
FROM eclipse-temurin:11-jre

WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy the built JAR from build stage (matching original: salary-0.3.0-RELEASE.jar)
COPY --from=build /java/target/salary-0.3.0-RELEASE.jar /app/salary.jar

# Copy config.yaml (matching original Dockerfile structure)
RUN mkdir -p /root/config
COPY --from=build /tmp/repo/salary/config.yaml /root/config/config.yaml

# Set environment variable for config file location
ENV CONFIG_FILE="/root/config/config.yaml"

EXPOSE 8080

# Run the Java application (matching original Dockerfile)
ENTRYPOINT ["java", "-jar", "/app/salary.jar"]