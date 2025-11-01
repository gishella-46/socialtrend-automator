#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     SocialTrend Automator - Initialization Script                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker and Docker Compose are installed${NC}"
echo ""

# Stop existing containers
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
docker-compose down 2>/dev/null || true
echo ""

# Remove old volumes (optional - uncomment if you want fresh start)
# echo -e "${YELLOW}🗑️  Removing old volumes...${NC}"
# docker-compose down -v 2>/dev/null || true
# echo ""

# Build and start containers
echo -e "${BLUE}🔨 Building Docker images...${NC}"
docker-compose build --no-cache
echo ""

echo -e "${BLUE}🚀 Starting containers...${NC}"
docker-compose up -d
echo ""

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 10

# Check service health
echo -e "${BLUE}🏥 Checking service health...${NC}"
echo ""

# Check PostgreSQL
if docker exec socialtrend_postgres pg_isready -U socialtrend_user -d socialtrend_db &> /dev/null; then
    echo -e "${GREEN}✅ PostgreSQL is ready${NC}"
else
    echo -e "${YELLOW}⏳ PostgreSQL is starting...${NC}"
fi

# Check Redis
if docker exec socialtrend_redis redis-cli ping &> /dev/null; then
    echo -e "${GREEN}✅ Redis is ready${NC}"
else
    echo -e "${YELLOW}⏳ Redis is starting...${NC}"
fi

# Wait a bit more for all services
echo ""
echo -e "${YELLOW}⏳ Waiting for all services...${NC}"
sleep 15

# Run database migrations (Laravel)
echo -e "${BLUE}📊 Running Laravel database migrations...${NC}"
docker exec socialtrend_backend php artisan migrate --force 2>/dev/null || echo -e "${YELLOW}⚠️  Migration failed or already run${NC}"
echo ""

# Setup Laravel (if needed)
echo -e "${BLUE}🔑 Generating Laravel application key (if needed)...${NC}"
docker exec socialtrend_backend php artisan key:generate --force 2>/dev/null || true
echo ""

# Generate Laravel API documentation
echo -e "${BLUE}📚 Generating Laravel API documentation...${NC}"
docker exec socialtrend_backend php artisan scribe:generate 2>/dev/null || echo -e "${YELLOW}⚠️  Documentation generation skipped${NC}"
echo ""

# Display status
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    ✅ SETUP COMPLETE! ✅                               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 Container Status:${NC}"
docker-compose ps
echo ""
echo -e "${BLUE}🌐 Access your application:${NC}"
echo ""
echo -e "${GREEN}   Frontend:${NC}     http://localhost"
echo -e "${GREEN}   Backend API:${NC}  http://localhost/api"
echo -e "${GREEN}   Laravel Docs:${NC} http://localhost/docs"
echo -e "${GREEN}   FastAPI Docs:${NC} http://localhost/automation/docs"
echo -e "${GREEN}   FastAPI ReDoc:${NC} http://localhost/automation/redoc"
echo ""
echo -e "${BLUE}📝 Useful Commands:${NC}"
echo -e "   View logs:        ${YELLOW}docker-compose logs -f${NC}"
echo -e "   Stop services:    ${YELLOW}docker-compose down${NC}"
echo -e "   Restart services: ${YELLOW}docker-compose restart${NC}"
echo -e "   Shell access:     ${YELLOW}docker exec -it socialtrend_backend bash${NC}"
echo ""
echo -e "${GREEN}✅ All services are running!${NC}"
echo ""
