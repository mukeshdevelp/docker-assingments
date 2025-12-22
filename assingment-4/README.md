# Assignment 4: Docker Compose for OT-Microservices

## Overview

Docker Compose setup for OT-Microservices with high availability. Code is cloned during Docker build, so no local code needed after initial build.

## Requirements

- Docker and Docker Compose installed
- Internet connection (for cloning during build)
- Ports: 3000, 3307, 8000, 9200, 9300

## Task Objectives

**Step 1:** Setup OT-Microservice - Clone code and run (code cloned during build)  
**Step 2:** Delete local code and run (services run from images)  
**Step 3:** Buddy runs without cloning (only needs dockerfiles)  
**Step 4:** High Availability - 2 replicas each for attendance, employee, salary  
**Bonus:** Run only Attendance and MySQL containers
Screenshot from 2025-12-22 10-51-20.png



## How to Complete

### Step 1: Build and Start

```bash
cd /home/mukesh/Downloads/docker/docker-assingments/assingment-4

# Build all images (code cloned during build)
docker-compose build

# Start with high availability (2 replicas each)
docker-compose up -d --scale attendance=2 --scale employee=2 --scale salary=2
```

### Step 2: Verify Services

```bash
# Check status
docker-compose ps

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/attendance/healthz
curl http://localhost:8000/employee/healthz
curl http://localhost:8000/salary/search/all
```

### Step 3: Delete Local Code and Verify

```bash
docker-compose down
# Delete local code if you want
docker-compose up -d --scale attendance=2 --scale employee=2 --scale salary=2
```

### Step 4: Verify High Availability

```bash
docker ps | grep attendance | wc -l  # Should be 2
docker ps | grep employee | wc -l    # Should be 2
docker ps | grep salary | wc -l      # Should be 2
```

### Step 5: Buddy Runs Without Cloning

Buddy needs: `docker-compose.yml`, `dockerfiles/`, `nginx/nginx.conf`, `docker-compose-bonus.yml`

```bash
docker-compose build && docker-compose up -d --scale attendance=2 --scale employee=2 --scale salary=2
```

## Service URLs

### Frontend
- **Main App**: http://localhost:3000
- **Employee Add**: http://localhost:3000/employee-add

### API Gateway (Port 8000)

**Health Checks:**
- Nginx: http://localhost:8000/health
- Attendance: http://localhost:8000/attendance/healthz
- Employee: http://localhost:8000/employee/healthz

**Create Employee** (creates Elasticsearch index):
```bash
curl -X POST http://localhost:8000/employee/create \
  -H "Content-Type: application/json" \
  -d '{"id":"emp001","name":"John Doe","job_role":"Software Engineer","joining_date":"2024-01-15","address":"123 Main St","location":"New York","status":"active","email":"john.doe@example.com","annual_package":120000,"phone_number":"+1-555-0123"}'
```

**Employee Endpoints:**
- Search all: http://localhost:8000/employee/search/all
- Search by ID: http://localhost:8000/employee/search?id=emp001

**Attendance:** `POST http://localhost:8000/attendance/create`, `GET http://localhost:8000/attendance/search?employee_id=emp001`  
**Salary:** http://localhost:8000/salary/search/all

**Note:** Create employee first for salary service (creates Elasticsearch index).

### Infrastructure

- **MySQL**: `localhost:3307` (root: `root@123`, db: `otmicroservices`, user: `otuser`, pass: `otpassword`)
- **Elasticsearch**: 
  - Health: http://localhost:9200/_cluster/health
  - Indices: http://localhost:9200/_cat/indices

## Bonus Assignment

```bash
# Start only Attendance and MySQL
docker-compose -f docker-compose-bonus.yml up -d --build

# Test
curl http://localhost:8081/attendance/healthz

# Stop
docker-compose -f docker-compose-bonus.yml down
```

## Common Commands

```bash
docker-compose logs [service-name] --tail=50  # View logs
docker-compose restart [service-name]         # Restart service
docker-compose down                            # Stop all
docker-compose build --no-cache [service-name] # Rebuild service
```

## Troubleshooting

**Services not starting:** `docker-compose logs [service-name]`  
**Salary 500 error:** Create employee first to create Elasticsearch index  
**Port conflicts:** `sudo netstat -tulpn | grep -E "3000|3307|8000|9200"`  
**Replicas not starting:** Check resources with `docker stats`

## Repository

- **Source**: https://github.com/opstree/OT-Microservices
- Code cloned during Docker build
- Original files never modified

---


