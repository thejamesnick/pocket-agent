# 🤖 PocketAgent

**Sovereign intelligence in every pocket.**

PocketAgent is a production-ready autonomous agent designed for the **Pocket-First** era. Powered by [OpenClaw](https://github.com/openclaw/openclaw), it's built to be personal, portable, and persistent. 

---

## ⚡ Quick Start

### Option A: Docker (Recommended)
```bash
docker compose up --build -d
```
*(Open http://localhost:18789 to start onboarding)*

### Option B: Local Node.js (No Docker)
```bash
chmod +x run_local.sh
./run_local.sh
```
*(Open http://localhost:18789 to start onboarding)*

---

## 📚 Detailed Documentation

- **[☁️ Cloud Deployment (GitHub Actions + VPS)](doc/cloud/README.md)**
- **[💻 Local Setup Guide](doc/local/README.md)**

---

## 📁 Project Structure

```
.
├── .github/workflows/
│   └── deploy.yml              # CI/CD — auto-deploy on push to main
├── doc/                        # Documentation
├── workspace/                  # ← This is your agent's brain
│   ├── SOUL.md                 # Personality & behaviour
│   ├── IDENTITY.md             # Name, emoji, color, description
│   ├── AGENTS.md               # Agent instructions & capabilities
│   ├── USER.md                 # Who the agent is helping
│   ├── TOOLS.md                # Environment-specific tool notes
│   ├── HEARTBEAT.md            # Periodic background tasks
│   ├── DEPLOY.md               # Deployment guide
│   ├── agents/                 # Sub-agents go here
│   └── skills/                 # Skills go here
├── Dockerfile                  # Main build (clones OpenClaw + workspace)
├── docker-compose.yml          # One-command deployment
├── run_local.sh                # Helper script for local run
├── entrypoint.sh               # Container startup script
├── .env.example                # Template for secrets
└── README.md                   # You are here
```

---

## 🧠 Customization Guide

### Personality (`workspace/SOUL.md`)

This is the most important file. It defines **who your agent is**. Write it like you're briefing a new employee:

- Who are they?
- How do they talk?
- What do they care about?
- What should they never do?

### Adding Sub-Agents

When you're ready to add specialized agents under your main one:

1. Create a folder: `workspace/agents/my-sub-agent/`
2. Add three files:
   - `IDENTITY.md` — ID, name, emoji
   - `SOUL.md` — Personality for that sub-agent
   - `AGENTS.md` — Instructions & capabilities
3. Reference the sub-agent in your main `workspace/AGENTS.md`

### Adding Skills

Skills teach your agent how to use tools and APIs:

1. Create a folder: `workspace/skills/my-skill/`
2. Add a `SKILL.md` with instructions
3. Optionally add `scripts/`, `package.json`, etc.


---

## 🔑 Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENCLAW_GATEWAY_TOKEN` | ✅ | Secret token to access the gateway |
| `OPENCLAW_GATEWAY_PORT` | ❌ | Gateway port (default: `18789`) |
| `OPENCLAW_GATEWAY_BIND` | ❌ | Bind address (default: `lan`) |
| `TELEGRAM_BOT_TOKEN` | ❌ | For Telegram integration |

Add your own LLM API keys as needed.

---

## 🛡️ Security

- **Never commit `.env`** — it's in `.gitignore`
- Use `openssl rand -hex 32` to generate your gateway token
- The default `docker-compose.yml` binds to `127.0.0.1` (localhost only)
- For production, use a reverse proxy (nginx, Caddy) with HTTPS

---

## 📄 License

MIT — do whatever you want with it.

---

*Powered by [OpenClaw](https://github.com/openclaw/openclaw).* 🤖
