# Assignment 2 - Part 2: OT-Microservices Application Deployment

## Overview

This assignment demonstrates deployment of a complete microservices architecture using Docker and Docker Compose. The OT-Microservices application consists of multiple services that work together: MySQL database, Attendance service, Elasticsearch, Employee service, Salary service, Nginx reverse proxy, and Frontend application.

## Requirements

- Docker installed and running
- Docker Compose installed
- Git (for cloning repository during build)
- Internet connection (for pulling images and cloning repository)
- Minimum 4GB RAM (for Elasticsearch)

## Task Objectives

### Step 1: MySQL and Attendance
- MySQL database container running
- Attendance microservice running and connected to MySQL
- Validate Attendance service

### Step 2: ES and Employee
- Elasticsearch container running
- Employee microservice running and connected to Elasticsearch
- Validate Employee service

### Step 3: Salary
- Salary microservice running
- Salary service connected to Employee and Attendance services
- Validate Salary service

### Step 4: Nginx Reverse Proxy
- Nginx container running
- Nginx configured as reverse proxy for:
  - Salary service
  - Employee service
  - Attendance service
- Validate Nginx proxy

### Step 5: Frontend
- Frontend application running
- Frontend connected to backend services via Nginx
- Validate Frontend

## Project Structure

```
assignment-2/part-2/
├── docker-compose.yml                    # Main orchestration file
├── dockerfiles/
│   ├── attendance/
│   │   └── Dockerfile                    # Attendance service dockerfile
│   ├── employee/
│   │   └── Dockerfile                    # Employee service dockerfile
│   ├── salary/
│   │   └── Dockerfile                    # Salary service dockerfile
│   └── frontend/
│       ├── Dockerfile                    # Frontend dockerfile
│       └── nginx-frontend.conf           # Frontend nginx config
├── nginx/
│   └── nginx.conf                        # Nginx reverse proxy configuration
└── README.md                             # This file
```

## Architecture

```
┌─────────────┐
│  Frontend   │ (Port 3000)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Nginx    │ (Port 80) - Reverse Proxy
└───┬───┬───┬─┘
    │   │   │
    ▼   ▼   ▼
┌────┐ ┌──────┐ ┌──────┐
│Salary│ │Employee│ │Attendance│
└──┬──┘ └───┬───┘ └───┬──┘
   │        │         │
   │        ▼         │
   │   ┌──────────┐  │
   │   │Elasticsearch│
   │   └──────────┘  │
   │                 │
   └────────┬────────┘
            ▼
      ┌──────────┐
      │  MySQL   │
      └──────────┘
```

## Services Overview

### MySQL (Step 1)
- **Image**: mysql:8.0
- **Container**: ot-mysql
- **Port**: 3306
- **Database**: otmicroservices
- **User**: otuser
- **Password**: otpassword

### Attendance Service (Step 1)
- **Port**: 8081
- **Container**: ot-attendance
- **Dependencies**: MySQL
- **Health Check**: http://localhost:8081/actuator/health

### Elasticsearch (Step 2)
- **Image**: elasticsearch:7.17.0
- **Container**: ot-elasticsearch
- **Ports**: 9200 (HTTP), 9300 (Transport)
- **Health Check**: http://localhost:9200/_cluster/health

### Employee Service (Step 2)
- **Port**: 8082
- **Container**: ot-employee
- **Dependencies**: Elasticsearch
- **Health Check**: http://localhost:8082/actuator/health

### Salary Service (Step 3)
- **Port**: 8083
- **Container**: ot-salary
- **Dependencies**: Employee, Attendance
- **Health Check**: http://localhost:8083/actuator/health

### Nginx Reverse Proxy (Step 4)
- **Image**: nginx:alpine
- **Container**: ot-nginx
- **Port**: 80
- **Routes**:
  - /attendance/ → attendance:8081
  - /employee/ → employee:8082
  - /salary/ → salary:8083

### Frontend (Step 5)
- **Port**: 3000
- **Container**: ot-frontend
- **Dependencies**: Nginx
- **Technology**: React (served via Nginx)

## Setup Instructions

### Step 1: Navigate to Project Directory

```bash
cd assignment-2/part-2
```

### Step 2: Build and Start All Services

Build all images and start all containers:

```bash
docker-compose up --build
```

This will:
1. Pull required base images (MySQL, Elasticsearch, Nginx)
2. Build microservice images from dockerfiles
3. Create Docker network (ot-network)
4. Create volumes (mysql-data, es-data)
5. Start services in dependency order:
   - MySQL (first)
   - Elasticsearch (second)
   - Attendance (after MySQL)
   - Employee (after Elasticsearch)
   - Salary (after Employee and Attendance)
   - Nginx (after Salary, Employee, Attendance)
   - Frontend (after Nginx)

### Step 3: Verify All Containers are Running

Check if all containers are running:

```bash
docker ps
```

You should see 7 containers:
- ot-mysql
- ot-elasticsearch
- ot-attendance
- ot-employee
- ot-salary
- ot-nginx
- ot-frontend

## Validation Steps

### Step 1 Validation: MySQL and Attendance

#### Validate MySQL

```bash
# Check MySQL is running
docker exec -it ot-mysql mysqladmin ping -h localhost

# Connect to MySQL and check database
docker exec -it ot-mysql mysql -u otuser -potpassword otmicroservices -e "SHOW DATABASES;"
```

#### Validate Attendance Service

```bash
# Check Attendance service health
curl http://localhost:8081/actuator/health

# Or check logs
docker logs ot-attendance

# Test Attendance endpoint
curl http://localhost:8081/api/attendance
```

Expected: Attendance service should be running and connected to MySQL.

### Step 2 Validation: ES and Employee

#### Validate Elasticsearch

```bash
# Check Elasticsearch cluster health
curl http://localhost:9200/_cluster/health

# Check Elasticsearch info
curl http://localhost:9200
```

Expected: Elasticsearch should return cluster health status.

#### Validate Employee Service

```bash
# Check Employee service health
curl http://localhost:8082/actuator/health

# Or check logs
docker logs ot-employee

# Test Employee endpoint
curl http://localhost:8082/api/employee
```

Expected: Employee service should be running and connected to Elasticsearch.

### Step 3 Validation: Salary

```bash
# Check Salary service health
curl http://localhost:8083/actuator/health

# Or check logs
docker logs ot-salary

# Test Salary endpoint
curl http://localhost:8083/api/salary
```

Expected: Salary service should be running and connected to both Employee and Attendance services.

### Step 4 Validation: Nginx Reverse Proxy

#### Validate Nginx is Running

```bash
# Check Nginx health
curl http://localhost/health

# Check Nginx logs
docker logs ot-nginx
```

#### Validate Proxy Routes

```bash
# Test Attendance through Nginx
curl http://localhost/attendance/api/attendance

# Test Employee through Nginx
curl http://localhost/employee/api/employee

# Test Salary through Nginx
curl http://localhost/salary/api/salary
```

Expected: All three services should be accessible through Nginx reverse proxy.

### Step 5 Validation: Frontend

```bash
# Check Frontend is accessible
curl http://localhost:3000

# Or open in browser
# http://localhost:3000
```

Expected: Frontend application should load and be able to communicate with backend services through Nginx.

## Complete Validation Checklist

Run these commands to verify all requirements:

```bash
# 1. Check all containers are running
docker ps

# 2. Validate MySQL
docker exec -it ot-mysql mysqladmin ping -h localhost

# 3. Validate Attendance (Step 1)
curl http://localhost:8081/actuator/health

# 4. Validate Elasticsearch (Step 2)
curl http://localhost:9200/_cluster/health

# 5. Validate Employee (Step 2)
curl http://localhost:8082/actuator/health

# 6. Validate Salary (Step 3)
curl http://localhost:8083/actuator/health

# 7. Validate Nginx Proxy (Step 4)
curl http://localhost/health
curl http://localhost/attendance/api/attendance
curl http://localhost/employee/api/employee
curl http://localhost/salary/api/salary

# 8. Validate Frontend (Step 5)
curl http://localhost:3000
```

## Service URLs

### Direct Service Access

- **Attendance**: http://localhost:8081
- **Employee**: http://localhost:8082
- **Salary**: http://localhost:8083
- **Elasticsearch**: http://localhost:9200
- **MySQL**: localhost:3306

### Through Nginx Proxy

- **Attendance**: http://localhost/attendance/
- **Employee**: http://localhost/employee/
- **Salary**: http://localhost/salary/
- **Nginx Health**: http://localhost/health

### Frontend

- **Frontend**: http://localhost:3000

## Troubleshooting

### Issue: Containers fail to start

**Solution**: Check logs for errors
```bash
docker-compose logs
```

Check specific service:
```bash
docker logs <container-name>
```

### Issue: Elasticsearch fails to start

**Solution**: 
1. Check if you have enough memory (Elasticsearch needs at least 2GB)
2. Increase Docker memory limit
3. Check Elasticsearch logs:
```bash
docker logs ot-elasticsearch
```

### Issue: Services cannot connect to each other

**Solution**: 
1. Verify all containers are on the same network:
```bash
docker network inspect assignment-2_part-2_ot-network
```

2. Check service names match in docker-compose.yml

3. Verify dependencies are met (check depends_on in docker-compose.yml)

### Issue: Nginx proxy not working

**Solution**:
1. Check Nginx configuration:
```bash
docker exec -it ot-nginx cat /etc/nginx/nginx.conf
```

2. Check Nginx logs:
```bash
docker logs ot-nginx
```

3. Verify backend services are accessible:
```bash
docker exec -it ot-nginx ping attendance
docker exec -it ot-nginx ping employee
docker exec -it ot-nginx ping salary
```

### Issue: Frontend cannot connect to backend

**Solution**:
1. Check Frontend environment variables
2. Verify Nginx is running and accessible
3. Check browser console for errors
4. Verify API URLs in Frontend configuration

### Issue: Build failures

**Solution**:
1. Check if repository is accessible:
```bash
curl https://github.com/opstree/OT-Microservices-Training
```

2. Check build logs:
```bash
docker-compose build --no-cache
```

3. Verify Java/Maven versions in dockerfiles

## Stopping Services

To stop all services:

```bash
docker-compose down
```

This stops and removes containers but keeps volumes.

## Clean Up

To remove everything including volumes:

```bash
docker-compose down -v
```

WARNING: This deletes all data including MySQL and Elasticsearch data.

## Starting Services in Steps (For Testing)

You can start services step by step to validate each step:

### Step 1: Start MySQL and Attendance

```bash
docker-compose up mysql attendance
```

### Step 2: Start Elasticsearch and Employee

```bash
docker-compose up elasticsearch employee
```

### Step 3: Start Salary

```bash
docker-compose up salary
```

### Step 4: Start Nginx

```bash
docker-compose up nginx
```

### Step 5: Start Frontend

```bash
docker-compose up frontend
```

## Network Configuration

All services communicate via Docker bridge network:
- **Network Name**: ot-network (or assignment-2_part-2_ot-network)
- **Driver**: bridge
- **Service Discovery**: Containers can reach each other using service names

## Environment Variables

### Attendance Service
- SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/otmicroservices
- SPRING_DATASOURCE_USERNAME: otuser
- SPRING_DATASOURCE_PASSWORD: otpassword
- SERVER_PORT: 8081

### Employee Service
- ELASTICSEARCH_HOST: elasticsearch
- ELASTICSEARCH_PORT: 9200
- SERVER_PORT: 8082

### Salary Service
- EMPLOYEE_SERVICE_URL: http://employee:8082
- ATTENDANCE_SERVICE_URL: http://attendance:8081
- SERVER_PORT: 8083

### Frontend
- REACT_APP_API_URL: http://nginx

## Repository Information

- **Source Repository**: https://github.com/opstree/OT-Microservices-Training
- All dockerfiles clone this repository during build process

## Notes

- Services start in dependency order automatically due to depends_on configuration
- Health checks ensure services are ready before dependent services start
- Data persistence is maintained through Docker volumes
- Nginx acts as a single entry point for all backend services
- Frontend communicates with backend through Nginx proxy
- All services use Java 11 for consistency

## Port Summary

- 80: Nginx Reverse Proxy
- 3000: Frontend
- 3306: MySQL
- 8081: Attendance Service
- 8082: Employee Service
- 8083: Salary Service
- 9200: Elasticsearch HTTP
- 9300: Elasticsearch Transport

