# FireWorks HTML Node.js — Docker & AWS ECS Deployment

A simple **FireWorks HTML website** served using **Node.js + Express**, containerized with Docker and deployable to **Amazon ECS Fargate** using **Amazon ECR** and an **Application Load Balancer (ALB)**.

## Architecture

```text
                         GitHub
                           |
                           v
                    Node.js + Express
                           |
                           v
                     Docker Image
                           |
                           v
                    Amazon ECR
                           |
                           v
                    ECS Fargate
                           |
                           v
                 Application Load Balancer
                           |
                           v
                     FireWorks App
```

---

# 1. Project Structure

```text
FireWorks-html-nodejs/
│
├── Dockerfile
├── .dockerignore
├── package.json
├── package-lock.json
├── server.js
├── index.html
├── tooplate-fireworks-composer.js
├── tooplate-fireworks-style.css
├── docker-compose.yml
│
└── terraform/
```

---

# 2. Application Requirements

Install the following:

- Node.js
- npm
- Git
- Docker
- AWS CLI
- AWS account

Verify:

```bash
node --version
npm --version
docker --version
aws --version
git --version
```

---

# 3. Clone the Repository

```bash
git clone https://github.com/tawsdevops-oss/FireWorks-html-nodejs.git
```

Go to the project:

```bash
cd FireWorks-html-nodejs
```

---

# 4. Run the Application Locally

Install Node.js dependencies:

```bash
npm install
```

Start the application:

```bash
npm start
```

The application can be accessed at:

```text
http://localhost:8080
```

---

# 5. Configure Application Port

For container and ECS deployment, this project uses **port 3000**.

The application reads the port from the environment variable:

```javascript
const PORT = process.env.PORT || 3000;
```

Recommended `server.js` configuration:

```javascript
const express = require('express');
const path = require('path');

const app = express();

const PORT = process.env.PORT || 3000;

app.use(express.static(__dirname));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

The `/health` endpoint is used by the ECS/ALB health check.

---

# 6. Test Node.js Application

Linux/Git Bash:

```bash
PORT=3000 npm start
```

Windows PowerShell:

```powershell
$env:PORT="3000"
npm start
```

Open:

```text
http://localhost:3000
```

Health check:

```text
http://localhost:3000/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

---

# 7. Dockerfile

The application uses Node.js 18.

Recommended Dockerfile:

```dockerfile
FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "start"]
```

### Dockerfile Explanation

| Instruction | Purpose |
|---|---|
| `FROM node:18` | Uses Node.js 18 base image |
| `WORKDIR /app` | Sets application working directory |
| `COPY package*.json ./` | Copies dependency files |
| `RUN npm install` | Installs Node.js dependencies |
| `COPY . .` | Copies application source |
| `ENV PORT=3000` | Configures application port |
| `EXPOSE 3000` | Documents container port |
| `CMD ["npm", "start"]` | Starts Node.js application |

---

# 8. .dockerignore

Create `.dockerignore`:

```text
node_modules
npm-debug.log
.git
.gitignore
.env
.vscode
terraform
README.md
docker-compose.yml
```

This prevents unnecessary files from being copied into the Docker image.

---

# 9. Build Docker Image

From the project root:

```bash
docker build -t fireworks-nodejs:1.0 .
```

Check the image:

```bash
docker images
```

Expected:

```text
REPOSITORY         TAG
fireworks-nodejs   1.0
```

---

# 10. Run Docker Container Locally

Run:

```bash
docker run -d \
  --name fireworks-app \
  -p 3000:3000 \
  fireworks-nodejs:1.0
```

Check the container:

```bash
docker ps
```

Expected:

```text
fireworks-app
```

---

# 11. Test Docker Container

Open:

```text
http://localhost:3000
```

Health check:

```bash
curl http://localhost:3000/health
```

Expected:

```json
{
  "status": "healthy"
}
```

Check container logs:

```bash
docker logs fireworks-app
```

Expected:

```text
Server running on port 3000
```

---

# 12. Debug Docker Container

Enter the container:

```bash
docker exec -it fireworks-app sh
```

Check the port:

```bash
echo $PORT
```

Expected:

```text
3000
```

Check Node.js:

```bash
node --version
```

Exit:

```bash
exit
```

---

# 13. Stop and Remove Container

Stop:

```bash
docker stop fireworks-app
```

Remove:

```bash
docker rm fireworks-app
```

---

# 14. AWS CLI Configuration

Configure AWS credentials:

```bash
aws configure
```

Verify AWS authentication:

```bash
aws sts get-caller-identity
```

Example:

```json
{
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/devops-user"
}
```

Set your AWS region:

```text
us-east-1
```

You can use another AWS region if required.

---

# 15. Create Amazon ECR Repository

Create the ECR repository:

```bash
aws ecr create-repository \
  --repository-name fireworks-nodejs \
  --region us-east-1
```

Verify:

```bash
aws ecr describe-repositories \
  --repository-names fireworks-nodejs \
  --region us-east-1
```

The ECR image URL will look like:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/fireworks-nodejs
```

Replace:

```text
123456789012
```

with your AWS Account ID.

---

# 16. Login Docker to Amazon ECR

Run:

```bash
aws ecr get-login-password \
  --region us-east-1 | \
docker login \
  --username AWS \
  --password-stdin \
  123456789012.dkr.ecr.us-east-1.amazonaws.com
```

Expected:

```text
Login Succeeded
```

---

# 17. Tag Docker Image

Tag the local image:

```bash
docker tag fireworks-nodejs:1.0 \
123456789012.dkr.ecr.us-east-1.amazonaws.com/fireworks-nodejs:1.0
```

Verify:

```bash
docker images
```

---

# 18. Push Image to Amazon ECR

Push the image:

```bash
docker push \
123456789012.dkr.ecr.us-east-1.amazonaws.com/fireworks-nodejs:1.0
```

Verify:

```bash
aws ecr describe-images \
  --repository-name fireworks-nodejs \
  --region us-east-1
```

---

# 19. ECS Architecture

The production deployment uses:

```text
Internet
   |
   v
Application Load Balancer
   |
   v
Target Group
   |
   v
ECS Fargate Service
   |
   v
ECS Task
   |
   v
Docker Container
   |
   v
Node.js + Express
   |
   v
Port 3000
```

---

# 20. ECS Fargate Configuration

Recommended configuration:

| Configuration | Value |
|---|---|
| Launch Type | Fargate |
| CPU | 0.25 vCPU |
| Memory | 0.5 GB |
| Container Name | `fireworks-container` |
| Container Port | `3000` |
| Protocol | TCP |
| Desired Tasks | `1` |
| Image | Amazon ECR image |

---

# 21. ECS Task Definition

The container configuration should contain:

```json
{
  "name": "fireworks-container",
  "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/fireworks-nodejs:1.0",
  "essential": true,
  "portMappings": [
    {
      "containerPort": 3000,
      "hostPort": 3000,
      "protocol": "tcp"
    }
  ],
  "environment": [
    {
      "name": "PORT",
      "value": "3000"
    },
    {
      "name": "NODE_ENV",
      "value": "production"
    }
  ]
}
```

Replace the ECR image URL with your own repository URL.

---

# 22. ECS IAM Roles

The ECS task requires appropriate IAM permissions.

At minimum, configure:

### ECS Task Execution Role

Used by ECS to:

- Pull the Docker image from ECR
- Send container logs to CloudWatch

The AWS managed policy commonly used is:

```text
AmazonECSTaskExecutionRolePolicy
```

Do not place AWS access keys inside the Docker image.

---

# 23. Application Load Balancer

Create an Application Load Balancer.

Recommended:

```text
Load Balancer:
Application Load Balancer

Scheme:
Internet-facing

Listener:
HTTP : 80
```

The ALB forwards traffic to the ECS task.

---

# 24. Target Group

Create a target group:

```text
Target type:
IP
```

Protocol:

```text
HTTP
```

Port:

```text
3000
```

Health check:

```text
Protocol: HTTP
Path: /health
Port: traffic-port
```

Expected HTTP response:

```text
200
```

---

# 25. Security Groups

## ALB Security Group

Allow:

```text
HTTP
TCP 80
Source: 0.0.0.0/0
```

For HTTPS:

```text
HTTPS
TCP 443
Source: 0.0.0.0/0
```

## ECS Task Security Group

Allow:

```text
TCP 3000
Source: ALB Security Group
```

The ECS container should not need to expose port `3000` directly to the Internet.

Traffic should flow:

```text
Internet
   |
   v
ALB : 80
   |
   v
ECS Task : 3000
```

---

# 26. ECS Service

Create an ECS service:

```text
Cluster:
fireworks-cluster

Service:
fireworks-service

Launch type:
Fargate

Desired count:
1
```

Attach:

```text
Application Load Balancer
        |
        v
Target Group
        |
        v
Port 3000
```

---

# 27. ECS Deployment Flow

```text
Developer
    |
    v
Git Push
    |
    v
GitHub
    |
    v
Docker Build
    |
    v
Docker Image
    |
    v
Amazon ECR
    |
    v
ECS Task Definition
    |
    v
ECS Service
    |
    v
Fargate Task
    |
    v
ALB
    |
    v
Browser
```

---

# 28. Check ECS Service

Run:

```bash
aws ecs describe-services \
  --cluster fireworks-cluster \
  --services fireworks-service \
  --region us-east-1
```

Verify:

```text
desiredCount = 1
runningCount = 1
```

---

# 29. Check ECS Tasks

List tasks:

```bash
aws ecs list-tasks \
  --cluster fireworks-cluster \
  --service-name fireworks-service \
  --region us-east-1
```

Get task details:

```bash
aws ecs describe-tasks \
  --cluster fireworks-cluster \
  --tasks <TASK-ARN> \
  --region us-east-1
```

---

# 30. CloudWatch Logs

Configure the ECS task definition to send application logs to CloudWatch.

Recommended log group:

```text
/ecs/fireworks-nodejs
```

Application logs should contain:

```text
Server running on port 3000
```

CloudWatch can then be used for troubleshooting:

```text
ECS Task
   |
   v
Container
   |
   v
stdout/stderr
   |
   v
CloudWatch Logs
```

---

# 31. Test Application Through ALB

Find the ALB DNS name:

```bash
aws elbv2 describe-load-balancers \
  --region us-east-1
```

Example:

```text
fireworks-alb-123456789.us-east-1.elb.amazonaws.com
```

Test:

```bash
curl http://fireworks-alb-123456789.us-east-1.elb.amazonaws.com
```

Health check:

```bash
curl http://fireworks-alb-123456789.us-east-1.elb.amazonaws.com/health
```

Expected:

```json
{
  "status": "healthy"
}
```

Open the application in a browser:

```text
http://<ALB-DNS-NAME>
```

---

# 32. Troubleshooting

## Container exits immediately

Check:

```bash
docker logs fireworks-app
```

---

## Port connection refused

Check:

```bash
docker ps
```

Verify:

```text
Host port      Container port
3000     ->    3000
```

Also verify:

```bash
docker logs fireworks-app
```

---

## ECS task keeps stopping

Check:

```bash
aws ecs describe-tasks \
  --cluster fireworks-cluster \
  --tasks <TASK-ARN> \
  --region us-east-1
```

Look for:

```text
stoppedReason
stopCode
containers[].reason
```

---

## ECS task cannot pull ECR image

Check:

- ECS Task Execution Role
- ECR repository
- ECR image tag
- AWS region
- ECS task networking
- Internet/NAT connectivity if using private subnets

---

## ALB health check fails

Verify:

```text
ALB
 |
 | HTTP
 v
ECS Task :3000
 |
 v
/health
```

Test locally:

```bash
curl http://localhost:3000/health
```

Expected:

```json
{
  "status": "healthy"
}
```

Also verify the ECS security group allows:

```text
TCP 3000
Source = ALB Security Group
```

---

# 33. Useful Docker Commands

Build:

```bash
docker build -t fireworks-nodejs:1.0 .
```

Run:

```bash
docker run -d \
  --name fireworks-app \
  -p 3000:3000 \
  fireworks-nodejs:1.0
```

List containers:

```bash
docker ps
```

View logs:

```bash
docker logs fireworks-app
```

Follow logs:

```bash
docker logs -f fireworks-app
```

Enter container:

```bash
docker exec -it fireworks-app sh
```

Stop:

```bash
docker stop fireworks-app
```

Remove:

```bash
docker rm fireworks-app
```

Remove image:

```bash
docker rmi fireworks-nodejs:1.0
```

---

# 34. Useful AWS Commands

Check AWS identity:

```bash
aws sts get-caller-identity
```

List ECR repositories:

```bash
aws ecr describe-repositories
```

List ECR images:

```bash
aws ecr describe-images \
  --repository-name fireworks-nodejs
```

List ECS clusters:

```bash
aws ecs list-clusters
```

List ECS services:

```bash
aws ecs list-services \
  --cluster fireworks-cluster
```

List ECS tasks:

```bash
aws ecs list-tasks \
  --cluster fireworks-cluster
```

---

# 35. Deployment Checklist

Use this checklist when deploying the application.

### Local

- [ ] Clone GitHub repository
- [ ] Run `npm install`
- [ ] Run application
- [ ] Test `localhost:3000`
- [ ] Test `/health`

### Docker

- [ ] Build Docker image
- [ ] Run container
- [ ] Check container logs
- [ ] Test application
- [ ] Test `/health`

### ECR

- [ ] Create ECR repository
- [ ] Login Docker to ECR
- [ ] Tag image
- [ ] Push image
- [ ] Verify image

### ECS

- [ ] Create ECS cluster
- [ ] Create IAM task execution role
- [ ] Create task definition
- [ ] Configure container port `3000`
- [ ] Configure CloudWatch logs
- [ ] Create ALB
- [ ] Create target group
- [ ] Configure health check `/health`
- [ ] Configure security groups
- [ ] Create ECS service

### Testing

- [ ] ECS task is RUNNING
- [ ] Target is HEALTHY
- [ ] ALB is reachable
- [ ] `/health` returns HTTP 200
- [ ] FireWorks website opens successfully
- [ ] CloudWatch logs show application startup

---

# 36. Final Production Architecture

```text
                       INTERNET
                           |
                           |
                           v
                +----------------------+
                | Application Load     |
                | Balancer             |
                | HTTP : 80            |
                +----------+-----------+
                           |
                           |
                           v
                +----------------------+
                | Target Group         |
                | HTTP : 3000          |
                | /health              |
                +----------+-----------+
                           |
                           |
                           v
                +----------------------+
                | ECS Fargate Service  |
                +----------+-----------+
                           |
                           v
                +----------------------+
                | ECS Task             |
                |                      |
                | fireworks-container  |
                |                      |
                | Node.js + Express    |
                | Port: 3000           |
                +----------+-----------+
                           |
                           v
                +----------------------+
                | Amazon ECR           |
                | Docker Image         |
                +----------------------+

                           |
                           v
                +----------------------+
                | CloudWatch Logs      |
                +----------------------+
```

---

# 37. CI/CD — Future Enhancement

The next stage of this project can automate the deployment:

```text
Developer
    |
    v
GitHub
    |
    v
GitHub Actions / Jenkins
    |
    +------------------+
    |                  |
    v                  v
Docker Build       Automated Tests
    |
    v
Amazon ECR
    |
    v
ECS Task Definition
    |
    v
ECS Service Update
    |
    v
Fargate
    |
    v
ALB
    |
    v
Production
```

A future CI/CD pipeline can automatically:

1. Checkout code
2. Run tests
3. Build Docker image
4. Tag image
5. Login to ECR
6. Push image
7. Register new ECS task definition
8. Update ECS service
9. Wait for deployment
10. Run health checks

---

## Application Summary

| Component | Technology |
|---|---|
| Frontend | HTML/CSS/JavaScript |
| Backend | Node.js |
| Framework | Express |
| Container | Docker |
| Registry | Amazon ECR |
| Compute | Amazon ECS Fargate |
| Load Balancer | Application Load Balancer |
| Logging | Amazon CloudWatch |
| Source Control | GitHub |
| Application Port | 3000 |
| Health Endpoint | `/health` |

---

## Author

**AWS & DevOps Training**

GitHub:

https://github.com/tawsdevops-oss
