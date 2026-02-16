#!/bin/bash
set -e

echo "🤖 Agent starting up..."

# ── Ensure directory structure exists ──
mkdir -p /home/node/.openclaw
mkdir -p /home/node/.openclaw/workspace
mkdir -p /home/node/.local/bin
mkdir -p /home/node/files
mkdir -p /home/node/.openclaw/workspace/memory

# ── Dynamic Configuration ──
# Check for keys and generate config.json
if [ -f "/app/scripts/configure_pocket_model.js" ]; then
    export POCKET_MODEL_TEMPLATE="/app/pocket_model.json"
    export POCKET_MODEL_OUTPUT="/home/node/.openclaw/config.json"
    
    # We use the system node to run the script
    node /app/scripts/configure_pocket_model.js
else
    echo "⚠️  Config script not found, skipping dynamic config."
fi

# ── Seed Workspace (First Run) ──
# If the persistent workspace is empty, populate it from the image
if [ -z "$(ls -A /home/node/.openclaw/workspace)" ]; then
    echo "🌱 Initializing workspace from image..."
    if [ -d "/app/workspace_init" ]; then
        cp -r /app/workspace_init/* /home/node/.openclaw/workspace/
        echo "✅ Workspace seeded."
    else
        echo "⚠️ No baked workspace found at /app/workspace_init"
    fi
else
    echo "💾 Persistent workspace found. Skipping initialization."
fi

# ── Run user-defined startup commands if they exist ──
CUSTOM_STARTUP="/home/node/.startup.sh"
if [ -f "$CUSTOM_STARTUP" ]; then
    echo "📜 Running custom startup script..."
    source "$CUSTOM_STARTUP"
fi

echo "✅ Ready. Launching OpenClaw..."

# Hand off to the CMD (node dist/index.js or whatever is passed)
exec "$@"
