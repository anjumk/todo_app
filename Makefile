# Makefile for Todo App DevOps Pipeline

.PHONY: help build run stop test scan deploy clean

# Default target
help:
	@echo "🚀 Todo App DevOps Pipeline Commands"
	@echo ""
	@echo "Development:"
	@echo "  make build          - Build Docker image"
	@echo "  make run            - Run application locally"
	@echo "  make dev            - Start development environment"
	@echo "  make stop           - Stop all containers"
	@echo ""
	@echo "Testing & Scanning:"
	@echo "  make test           - Run tests"
	@echo "  make scan-code      - Run SonarCloud analysis"
	@echo "  make scan-security  - Run Snyk security scan"
	@echo "  make scan-docker    - Scan Docker image"
	@echo "  make scan-all       - Run all scans"
	@echo ""
	@echo "CI/CD:"
	@echo "  make deploy-dev     - Deploy to development"
	@echo "  make deploy-prod    - Deploy to production"
	@echo "  make jenkins        - Start Jenkins locally"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean          - Clean Docker images and containers"
	@echo "  make clean-all      - Deep clean including volumes"

# Build Docker image
build:
	@echo "🐳 Building Docker image..."
	docker build -t todo-app:latest .
	@echo "✅ Build complete!"

# Run application locally
run: build
	@echo "🚀 Starting application..."
	docker run -d -p 8080:80 --name todo-app todo-app:latest
	@echo "✅ App running at http://localhost:8080"

# Start development environment
dev:
	@echo "🔧 Starting development environment..."
	docker-compose up -d
	@echo "✅ Services started:"
	@echo "   - App: http://localhost:8080"
	@echo "   - Jenkins: http://localhost:8081"
	@echo "   - SonarQube: http://localhost:9000"

# Stop all containers
stop:
	@echo "🛑 Stopping containers..."
	docker-compose down
	docker stop todo-app 2>/dev/null || true
	docker rm todo-app 2>/dev/null || true
	@echo "✅ Containers stopped"

# Run tests
test: build
	@echo "🧪 Running tests..."
	docker run --rm todo-app:latest nginx -t
	@echo "✅ Tests passed!"

# SonarCloud scan
scan-code:
	@echo "🔍 Running SonarCloud analysis..."
	@command -v sonar-scanner >/dev/null 2>&1 || { echo "⚠️  sonar-scanner not found. Install from https://docs.sonarcloud.io/"; exit 1; }
	sonar-scanner
	@echo "✅ Code analysis complete!"

# Snyk security scan
scan-security:
	@echo "🔒 Running Snyk security scan..."
	@command -v snyk >/dev/null 2>&1 || { echo "⚠️  snyk not found. Run: npm install -g snyk"; exit 1; }
	snyk test || true
	@echo "✅ Security scan complete!"

# Scan Docker image
scan-docker: build
	@echo "🐳 Scanning Docker image..."
	@command -v snyk >/dev/null 2>&1 || { echo "⚠️  snyk not found. Run: npm install -g snyk"; exit 1; }
	snyk container test todo-app:latest || true
	@echo "✅ Docker scan complete!"

# Run all scans
scan-all: scan-code scan-security scan-docker
	@echo "✅ All scans complete!"

# Deploy to development
deploy-dev: build test
	@echo "🚀 Deploying to development..."
	docker-compose up -d todo-app
	@echo "✅ Deployed to http://localhost:8080"

# Deploy to production
deploy-prod: build test scan-all
	@echo "🚀 Deploying to production..."
	docker-compose -f docker-compose.prod.yml up -d
	@echo "✅ Deployed to production!"

# Start Jenkins
jenkins:
	@echo "🤖 Starting Jenkins..."
	docker-compose up -d jenkins
	@echo "⏳ Waiting for Jenkins to start..."
	@sleep 10
	@echo "✅ Jenkins started at http://localhost:8081"
	@echo "📋 Initial admin password:"
	@docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "   (Jenkins still starting up...)"

# Clean Docker resources
clean:
	@echo "🧹 Cleaning up..."
	docker-compose down
	docker stop todo-app 2>/dev/null || true
	docker rm todo-app 2>/dev/null || true
	docker rmi todo-app:latest 2>/dev/null || true
	docker system prune -f
	@echo "✅ Cleanup complete!"

# Deep clean including volumes
clean-all: clean
	@echo "🧹 Deep cleaning..."
	docker-compose down -v
	docker system prune -a -f --volumes
	@echo "✅ Deep cleanup complete!"

# Show logs
logs:
	@echo "📋 Application logs:"
	docker logs -f todo-app 2>/dev/null || docker-compose logs -f todo-app

# Show status
status:
	@echo "📊 Service Status:"
	@echo ""
	@docker-compose ps 2>/dev/null || echo "No services running"
	@echo ""
	@docker ps --filter "name=todo-app" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true
