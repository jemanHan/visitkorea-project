#!/bin/bash
# Docker Compose Development Script (with Prisma Studio)

echo "🐳 Starting VisitKorea Development Environment"
echo "============================================="

# Start with development profile (includes Prisma Studio)
docker-compose --profile dev up --build -d

echo "✅ Development environment started!"
echo "📋 Service URLs:"
echo "   Backend API: http://localhost:3002"
echo "   Prisma Studio: http://localhost:5555"
echo "   Health Check: http://localhost:3002/health"
