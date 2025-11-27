# Assignment 2 - Part 1: S3Hibernate Application with MySQL

## Overview

This assignment demonstrates containerization of a Spring 3 Hibernate application with MySQL database. The setup includes two Docker containers: one for MySQL database and one for the S3Hibernate Spring application running on Tomcat.

## Requirements

- Docker installed and running
- Docker Compose installed
- Git (for cloning repository during build)
- Internet connection (for pulling images and cloning repository)

## Task Objectives

1. S3Hibernate App running in Docker Container
2. MySQL container running
3. Ability to ping MySQL Container from S3H container
4. Database connectivity established between application and MySQL

## Project Structure

```
assignment-2/part-1/
├── dockerfile          # Dockerfile for building S3Hibernate application
├── docker-compose.yml  # Docker Compose configuration for both containers
└── README.md          # This file
```

## Architecture

- **MySQL Container**: Runs MySQL 8.0 database server
- **S3Hibernate Container**: Runs Spring 3 Hibernate application on Tomcat 7
- **Network**: Both containers communicate via Docker bridge network (app-network)
- **Volume**: MySQL data persisted in Docker volume (mysql-data)

## Files Description

### dockerfile

Multi-stage build Dockerfile:
- **Build Stage**: Uses Maven 3.3 with JDK 8 to clone and build the Spring application from GitHub
- **Runtime Stage**: Uses Tomcat 7 with JRE 7 Alpine to run the WAR file
- Installs `iputils` package for ping utility (required for connectivity testing)

### docker-compose.yml

Orchestrates both containers:
- **mysql service**: MySQL 8.0 database with health checks
- **s3hibernate service**: Spring application that depends on MySQL being healthy
- Shared network for container communication
- Persistent volume for MySQL data

## Setup Instructions

### Step 1: Navigate to Project Directory

```bash
cd assignment-2/part-1
```

### Step 2: Build and Start Containers

Build the images and start both containers:

```bash
docker-compose up --build
```

This command will:
- Build the S3Hibernate application image from the dockerfile
- Pull the MySQL 8.0 image
- Create the Docker network (app-network)
- Create the MySQL data volume (mysql-data)
- Start MySQL container and wait for it to be healthy
- Start S3Hibernate container after MySQL is ready

### Step 3: Verify Containers are Running

Check if both containers are running:

```bash
docker ps
```

You should see both `mysql-container` and `s3hibernate-container_2` in the list with status "Up".

### Step 4: Test Ping Connectivity (Requirement #3)

Test if S3Hibernate container can ping MySQL container:

```bash
docker exec -it s3hibernate-container_2 ping -c 4 mysql
```

Expected output: Successful ping responses showing connectivity between containers.

### Step 5: Verify Database Connectivity

#### Option A: Check Application Logs

View the S3Hibernate container logs to verify database connection:

```bash
docker logs s3hibernate-container_2
```

Look for messages like:
- "Hibernate initialized"
- "Connected to database"
- "DataSource initialized"
- Any connection errors

To follow logs in real-time:

```bash
docker logs -f s3hibernate-container_2
```

#### Option B: Test MySQL Connection Directly

Connect to MySQL container and verify database:

```bash
docker exec -it mysql-container mysql -u s3user -ps3password s3hibernate -e "SHOW TABLES;"
```

Or enter MySQL interactive mode:

```bash
docker exec -it mysql-container mysql -u s3user -ps3password s3hibernate
```

Inside MySQL, run:
```sql
SHOW TABLES;
SELECT DATABASE();
EXIT;
```

#### Option C: Test Application Endpoint

Access the application to verify it's working with database:

```bash
curl http://localhost:8080
```

Or open in browser:
```
http://localhost:8080
```

If the application loads and displays data, database connectivity is established.

### Step 6: Verify Network Connectivity

Check that both containers are on the same network:

```bash
docker network inspect docker-assingments_app-network
```

This should show both containers listed in the network.

## Verification Checklist

Run these commands to verify all requirements:

```bash
# 1. Check containers are running
docker ps

# 2. Test ping from S3Hibernate to MySQL (Requirement #3)
docker exec -it s3hibernate-container_2 ping -c 4 mysql

# 3. Check application logs for database connection
docker logs s3hibernate-container_2 | grep -i "database\|hibernate\|connection\|mysql"

# 4. Test application endpoint
curl http://localhost:8080

# 5. Verify MySQL database exists
docker exec -it mysql-container mysql -u s3user -ps3password s3hibernate -e "SHOW DATABASES;"
```

## Troubleshooting

### Issue: Containers fail to start

**Solution**: Check logs for errors
```bash
docker-compose logs
```

### Issue: Cannot ping MySQL from S3Hibernate container

**Solution**: Verify both containers are on the same network
```bash
docker network ls
docker network inspect docker-assingments_app-network
```

### Issue: Database connection errors in logs

**Solution**: 
1. Verify MySQL is healthy:
   ```bash
   docker exec -it mysql-container mysqladmin ping -h localhost
   ```

2. Check environment variables in docker-compose.yml match database credentials

3. Verify MySQL container is ready before S3Hibernate starts (healthcheck should handle this)

### Issue: Application not accessible on port 8080

**Solution**: 
1. Check if port 8080 is already in use:
   ```bash
   netstat -tuln | grep 8080
   ```

2. Verify container is running:
   ```bash
   docker ps
   ```

3. Check container logs:
   ```bash
   docker logs s3hibernate-container_2
   ```

## Stopping Containers

To stop the containers:

```bash
docker-compose down
```

This stops and removes containers but keeps the MySQL data volume.

## Clean Up

To remove everything including volumes:

```bash
docker-compose down -v
```

To check ping
```bash
docker exec -it s3hibernate-container_2 ping -c 4 mysql
```
This will:
- Stop and remove containers
- Remove the network
- Remove the MySQL data volume (WARNING: This deletes all database data)

## Container Details

### MySQL Container

- **Image**: mysql:8.0
- **Container Name**: mysql-container
- **Port**: 3306 (mapped to host 3306)
- **Database**: s3hibernate
- **User**: s3user
- **Password**: s3password
- **Root Password**: root@123
- **Volume**: mysql-data (persistent storage)

### S3Hibernate Container

- **Image**: Built from dockerfile
- **Container Name**: s3hibernate-container_2
- **Port**: 8080 (mapped to host 8080)
- **Base Image**: tomcat:7-jre7-alpine
- **Application**: Spring3HibernateApp.war deployed on Tomcat
- **Network**: app-network (can communicate with mysql using hostname "mysql")

## Environment Variables

The S3Hibernate container uses these environment variables for database connection:

- SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/s3hibernate
- SPRING_DATASOURCE_USERNAME: s3user
- SPRING_DATASOURCE_PASSWORD: s3password
- SPRING_DATASOURCE_DRIVER_CLASS_NAME: com.mysql.cj.jdbc.Driver

## Network Configuration

Both containers communicate via Docker bridge network:
- **Network Name**: app-network
- **Driver**: bridge
- **Service Discovery**: Containers can reach each other using service names (mysql, s3hibernate)

## Repository Information

- **Source Repository**: https://github.com/opstree/spring3hibernate.git
- The dockerfile clones this repository during build process

## Notes

- The build process skips tests and dependency-check to avoid build failures
- MySQL healthcheck ensures database is ready before application starts
- Data persistence is maintained through Docker volumes
- The ping utility (iputils) is installed for network connectivity testing as per assignment requirements

