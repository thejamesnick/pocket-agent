#!/bin/bash
set -e

# Configuration
ENGINE_REPO="https://github.com/openclaw/openclaw.git"
ENGINE_DIR=".openclaw-engine"

# 1. Check prerequisites
if ! command -v node &> /dev/null; then echo "❌ Node.js is required."; exit 1; fi
if ! command -v pnpm &> /dev/null; then echo "❌ pnpm is required (npm install -g pnpm)."; exit 1; fi
if ! command -v git &> /dev/null; then echo "❌ git is required."; exit 1; fi

# 2. Setup Engine
if [ ! -d "$ENGINE_DIR" ]; then
    echo "⬇️  Cloning OpenClaw engine..."
    git clone "$ENGINE_REPO" "$ENGINE_DIR"
else
    echo "✅ Engine already cloned. Pulling latest..."
    cd "$ENGINE_DIR" && git pull && cd ..
fi

# 3. Build Engine
echo "📦 Installing dependencies & building..."
cd "$ENGINE_DIR"
pnpm install --frozen-lockfile
pnpm build
cd ..

# 4. Prepare Configuration
if [ ! -f .env ]; then
    echo "⚠️  No .env file found. Copying from .env.example..."
    cp .env.example .env
fi

# Load .env vars
export $(grep -v '^#' .env | xargs)

# 5. Run
echo "🚀 Starting PocketAgent (Local Mode)..."
echo "   Gatekeeper: http://localhost:${OPENCLAW_GATEWAY_PORT:-18789}"

# ── Dynamic Configuration (Local) ──
export POCKET_MODEL_TEMPLATE="$(pwd)/openclaw.json"
export POCKET_MODEL_OUTPUT="$(pwd)/openclaw-runtime.json"
# We need to tell the gateway to use this config? 
# OpenClaw usually looks in ~/.openclaw/config.json or we can pass a config path?
# If we can't pass a config path, we might need to copy it to ~/.openclaw or set XDG_CONFIG_HOME.
# Let's set XDG_CONFIG_HOME to a local .data directory to avoid messing with user's actual home?
# Or we can just set it to the current directory if OpenClaw supports it.
# The standard is XDG_CONFIG_HOME.

export XDG_CONFIG_HOME="$(pwd)/.local-config"
mkdir -p "$XDG_CONFIG_HOME"
export POCKET_MODEL_OUTPUT="$XDG_CONFIG_HOME/config.json"

if [ -f "scripts/configure_pocket_model.js" ]; then
    echo "⚙️  Generating runtime config..."
    node scripts/configure_pocket_model.js
else
    echo "⚠️  Config script not found."
fi

# We run the built engine, pointing it to our workspace
# Note: We use absolute path for workspace to be safe
WORKSPACE_ABS_PATH="$(pwd)/workspace"

# We start the agent from the engine directory
cd "$ENGINE_DIR"

# Run the gateway command
node dist/index.js gateway \
    --bind "${OPENCLAW_GATEWAY_BIND:-127.0.0.1}" \
    --port "${OPENCLAW_GATEWAY_PORT:-18789}" \
    --allow-unconfigured \
    --workspace "$WORKSPACE_ABS_PATH"
