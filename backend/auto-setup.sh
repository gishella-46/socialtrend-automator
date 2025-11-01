#!/bin/bash
# Backend Auto-Setup Script (Bash)
# Script untuk rebuild backend dan menjalankan next steps secara otomatis

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  🚀 Backend Laravel 11 - Auto Setup"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Check Docker
echo "🔍 Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo "   Please start Docker and try again."
    exit 1
fi
echo "✅ Docker is running"
echo ""

# Step 1: Rebuild Backend
echo "═══════════════════════════════════════════════════════════"
echo "Step 1: Rebuilding Backend Container..."
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "🔨 Building Docker image (this may take a few minutes)..."

docker-compose build backend || {
    echo "❌ Docker build failed!"
    exit 1
}

echo "✅ Docker image built successfully"
echo ""

echo "🚀 Starting backend container..."
docker-compose up -d backend || {
    echo "❌ Failed to start backend container!"
    exit 1
}

echo "✅ Backend container started"
echo ""

# Wait for container to be ready
echo "⏳ Waiting for backend to be ready (10 seconds)..."
sleep 10
echo ""

# Step 2: Run Migrations
echo "═══════════════════════════════════════════════════════════"
echo "Step 2: Running Database Migrations..."
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "📊 Running migrations..."
docker-compose exec -T backend php artisan migrate --force || {
    echo "⚠️  Migration failed, trying to continue anyway..."
}
echo "✅ Migrations completed"
echo ""

# Step 3: Generate App Key
echo "═══════════════════════════════════════════════════════════"
echo "Step 3: Generating Application Key..."
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "🔑 Generating app key..."
docker-compose exec -T backend php artisan key:generate --force || {
    echo "⚠️  App key generation failed (may already exist)"
}
echo "✅ App key generated"
echo ""

# Step 4: Cache Configuration
echo "═══════════════════════════════════════════════════════════"
echo "Step 4: Optimizing Application..."
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "⚡ Caching configuration..."
docker-compose exec -T backend php artisan config:cache
docker-compose exec -T backend php artisan route:cache
echo "✅ Application optimized"
echo ""

# Final Status
echo "═══════════════════════════════════════════════════════════"
echo "  ✅ SETUP COMPLETE!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📊 Container Status:"
docker-compose ps backend
echo ""
echo "🌐 API Endpoints:"
echo "   - Main:      http://localhost/api"
echo "   - Health:     http://localhost/api/health"
echo "   - Register:   http://localhost/api/register"
echo "   - Login:      http://localhost/api/login"
echo ""
echo "📝 Next Steps:"
echo "   - Start queue worker: docker-compose exec backend php artisan queue:work redis --queue=uploads"
echo "   - Run scheduler: docker-compose exec backend php artisan schedule:run"
echo "   - Or use cron for scheduler (every minute)"
echo ""
echo "═══════════════════════════════════════════════════════════"


















