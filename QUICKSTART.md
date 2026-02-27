# 🚀 Quick Start - DevOps Pipeline

## Fastest way to get started:

### 1. Start Docker Services
```bash
docker-compose up -d
```

### 2. Access Services
- **App**: http://localhost:8080
- **Jenkins**: http://localhost:8081
- **SonarQube**: http://localhost:9000 (admin/admin)

### 3. Setup Credentials
```bash
# Get Jenkins initial password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 4. Configure Tokens
Add in Jenkins → Credentials:
- `sonarcloud-token` - from https://sonarcloud.io
- `snyk-token` - from https://snyk.io
- `docker-registry-credentials` - Docker Hub login

### 5. Run Pipeline
```bash
# Commit and push to trigger pipeline
git add .
git commit -m "feat: your changes"
git push
```

## Common Commands

### Docker
```bash
# Build image
docker build -t todo-app:latest .

# Run container
docker run -d -p 8080:80 todo-app:latest

# View logs
docker logs -f <container-id>

# Stop all
docker-compose down
```

### Security Scans
```bash
# Snyk code scan
snyk test

# Snyk Docker scan
snyk container test todo-app:latest

# SonarCloud scan
sonar-scanner
```

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "feat: description"

# Push for CI/CD
git push -u origin feature/my-feature

# Merge to main (after checks pass)
git checkout main
git merge feature/my-feature
git push origin main
```

## Pipeline Status Checks

✅ **Code Quality** - SonarCloud  
✅ **Security Scan** - Snyk  
✅ **Docker Build** - Success  
✅ **Container Test** - Healthy  
✅ **Quality Gate** - Passed  

## Troubleshooting

### Jenkins won't start?
```bash
docker-compose restart jenkins
docker logs jenkins
```

### SonarQube not ready?
```bash
# Wait 2-3 minutes for startup
docker logs sonarqube
```

### Docker permission denied?
```bash
# Check Rancher Desktop is running
docker ps
```

## Need Help?
See full guide: [DEVOPS_SETUP.md](DEVOPS_SETUP.md)
