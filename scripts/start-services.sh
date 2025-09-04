#!/bin/bash
# Start VisitKorea Services (keeping existing Docker)

echo "🚀 Starting VisitKorea Services..."
echo "=================================="

# 1. Start existing PostgreSQL container
echo "📦 Starting PostgreSQL container..."
docker start vk-postgres
sleep 3

# 2. Check if container is running
if docker ps | grep -q vk-postgres; then
    echo "✅ PostgreSQL: Running"
else
    echo "❌ PostgreSQL: Failed to start"
    exit 1
fi

# 3. Update environment variables if needed
echo "🔧 Checking environment variables..."
if [ -f "update-env.sh" ]; then
    ./update-env.sh
fi

# 4. Sync database schema
echo "🗄️ Syncing database schema..."
cd apps/backend
export DATABASE_URL="postgresql://vk:vk@localhost:5432/vk?schema=public"
npx prisma db push --schema=../../packages/db/prisma/schema.prisma

# 5. Start backend server
echo "⚡ Starting backend server..."
echo "Backend will be available at: http://localhost:3002"
echo "Press Ctrl+C to stop the server"
npm run dev
