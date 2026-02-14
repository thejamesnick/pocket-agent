# 💻 Running PocketAgent Locally (No Docker)

You can run PocketAgent directly on your machine. We've included a helper script to manage the engine for you.

## 📋 Requirements

- **Node.js:** v22 or newer.
- **pnpm:** (`npm install -g pnpm`)
- **Git**

## 🚀 Quick Run

We've included a script that handles everything for you (cloning the engine, building it, and linking your workspace).

```bash
# Run the agent
chmod +x run_local.sh  # (only needed once)
./run_local.sh
```

**Then open http://localhost:18789 to start the onboarding process.**

That's it! The script will:
1.  Download the latest OpenClaw engine to a hidden folder (`.openclaw-engine`).
2.  Install dependencies and build it.
3.  Start it, using **YOUR** local `workspace/` folder for configuration.

## 🔄 Updates

To update both your agent's config (if you pulled changes) and the underlying engine:

```bash
./run_local.sh
```
(The script automatically pulls the latest engine code every time you run it).

## 🛑 Stopping

Press `Ctrl+C` to stop.
