#!/bin/bash
# EdAgent AI - Quick Start Setup Script
# Автоматическая установка и запуск приложения

set -e

echo "🚀 EdAgent AI - Automated Setup"
echo "================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    else
        echo -e "${GREEN}✓ $1 found${NC}"
        return 0
    fi
}

# Check Docker
if check_command docker; then
    DOCKER_INSTALLED=true
else
    echo "Docker not found. Install from https://www.docker.com/products/docker-desktop"
    DOCKER_INSTALLED=false
fi

# Check Docker Compose
if check_command docker-compose; then
    COMPOSE_INSTALLED=true
else
    echo "Docker Compose not found. Install Docker Desktop which includes Compose"
    COMPOSE_INSTALLED=false
fi

if [ "$DOCKER_INSTALLED" = false ] || [ "$COMPOSE_INSTALLED" = false ]; then
    echo -e "${RED}❌ Please install Docker and Docker Compose${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites installed${NC}\n"

# Setup .env file
echo -e "${BLUE}⚙️  Setting up environment configuration...${NC}"

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file from template${NC}"
    echo -e "${BLUE}⚠️  Please edit .env file with your API keys:${NC}"
    echo "   - OPENAI_API_KEY"
    echo "   - SENDGRID_API_KEY"
    echo "   - HH_API_KEY (optional)"
    read -p "Press Enter to continue..."
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

echo ""

# Create project directories
echo -e "${BLUE}📁 Creating project structure...${NC}"
mkdir -p backend/app/{api,services,db}
mkdir -p frontend
mkdir -p kubernetes
mkdir -p monitoring

echo -e "${GREEN}✓ Project structure created${NC}\n"

# Build containers
echo -e "${BLUE}🔨 Building Docker containers...${NC}"
docker-compose build --no-cache

echo -e "${GREEN}✓ Containers built successfully${NC}\n"

# Start services
echo -e "${BLUE}🚀 Starting services...${NC}"
docker-compose up -d

echo -e "${GREEN}✓ Services started${NC}\n"

# Wait for services to be ready
echo -e "${BLUE}⏳ Waiting for services to be ready...${NC}"
sleep 10

# Health checks
echo -e "${BLUE}🏥 Performing health checks...${NC}"

# Check Backend
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend is running${NC}"
else
    echo -e "${RED}❌ Backend is not responding${NC}"
fi

# Check Frontend
if curl -s http://localhost > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend is running${NC}"
else
    echo -e "${RED}❌ Frontend is not responding${NC}"
fi

# Check Database
if docker-compose exec -T postgres pg_isready -U edagent_user -d edagent_db > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Database is ready${NC}"
else
    echo -e "${RED}❌ Database is not responding${NC}"
fi

# Check Redis
if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Redis is ready${NC}"
else
    echo -e "${RED}❌ Redis is not responding${NC}"
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✅ EdAgent AI is running!${NC}"
echo -e "${GREEN}================================${NC}\n"

echo -e "${BLUE}📍 Access points:${NC}"
echo "   Frontend:        http://localhost"
echo "   Backend API:     http://localhost:8000/api"
echo "   API Docs:        http://localhost:8000/api/docs"
echo "   Prometheus:      http://localhost:9090"
echo "   Grafana:         http://localhost:3000 (admin/admin)"
echo ""

echo -e "${BLUE}📚 Next steps:${NC}"
echo "   1. Open http://localhost in your browser"
echo "   2. Go through all 3 phases of the application"
echo "   3. Check API documentation at http://localhost:8000/api/docs"
echo ""

echo -e "${BLUE}🛠️  Useful commands:${NC}"
echo "   View logs:       docker-compose logs -f backend"
echo "   Stop services:   docker-compose down"
echo "   Restart:         docker-compose restart"
echo "   Scale backend:   docker-compose up -d --scale backend=3"
echo ""

echo -e "${BLUE}📖 Documentation:${NC}"
echo "   Full README:     See README.md"
echo "   API Docs:        http://localhost:8000/api/docs"
echo "   Troubleshooting: See README.md #Troubleshooting"
echo ""

echo -e "${GREEN}Happy building! 🎉${NC}"
