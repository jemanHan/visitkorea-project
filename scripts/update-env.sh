#!/bin/bash
# Environment Variables Update Script

echo "🔧 VisitKorea Environment Variables Updater"
echo "=========================================="

# Function to update environment variable
update_env() {
    local key=$1
    local current_value=$2
    local new_value=$3
    local file=$4
    
    if [ "$current_value" != "$new_value" ]; then
        echo "�� Updating $key: $current_value → $new_value"
        sed -i "s|$key=$current_value|$key=$new_value|g" "$file"
    else
        echo "✅ $key is already up to date: $current_value"
    fi
}

# Check if .env.local exists
if [ ! -f "apps/backend/.env.local" ]; then
    echo "❌ .env.local not found. Creating from template..."
    cp config/.env.example apps/backend/.env.local
fi

# Get current values
CURRENT_IP=$(grep "WAS_SERVER_IP=" apps/backend/.env.local | cut -d'=' -f2)
CURRENT_PORT=$(grep "PORT=" apps/backend/.env.local | cut -d'=' -f2)

echo "Current WAS_SERVER_IP: $CURRENT_IP"
echo "Current PORT: $CURRENT_PORT"

# Get new values (you can modify these)
NEW_IP="13.209.108.148"
NEW_PORT="3002"

# Update if needed
update_env "WAS_SERVER_IP" "$CURRENT_IP" "$NEW_IP" "apps/backend/.env.local"
update_env "PORT" "$CURRENT_PORT" "$NEW_PORT" "apps/backend/.env.local"

echo "✅ Environment variables updated!"
echo "📋 Current configuration:"
echo "   WAS_SERVER_IP: $(grep "WAS_SERVER_IP=" apps/backend/.env.local | cut -d'=' -f2)"
echo "   PORT: $(grep "PORT=" apps/backend/.env.local | cut -d'=' -f2)"
