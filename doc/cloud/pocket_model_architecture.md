# PocketModel Architecture (The "Failover Fortress")

This document defines the **Direct Integration** strategy for the PocketModel. 
Instead of running a separate gateway service, we bake the failover logic directly into the OpenClaw configuration.

**Goal:** Zero external dependencies. Just one config file (`openclaw.json`).

---

## The Hierarchy

### 1. Primary: Antigravity Core
**Model:** `gemini-1.5-flash`
**Role:** High-speed daily driver.

### 2. The PocketModel (Fallback Mesh)
When the Primary stumbles, the agent automatically retries with:
1.  **Groq** (`llama-3.1-8b-instant`)
2.  **OpenRouter** (`deepseek/deepseek-chat`)
3.  **GitHub** (`mistral-large`)

---

## Technical Implementation (Direct Config)

We use the native `fallbacks` capability in `openclaw.json`.

### `openclaw.json` Template

```json
{
  "auth": {
    "google": {
      "api_key": "${GEMINI_API_KEY}",
      "provider": "google",
      "label": ":pocketmodel-core" 
    },
    "groq": {
      "api_key": "${GROQ_API_KEY}",
      "provider": "groq",
      "label": ":pocketmodel-fast"
    },
    "openrouter": {
      "api_key": "${OPENROUTER_API_KEY}",
      "provider": "openrouter",
      "label": ":pocketmodel-brain"
    },
    "github": {
      "api_key": "${GITHUB_TOKEN}",
      "provider": "github", 
      "label": ":pocketmodel-anchor"
    }
  },
  "models": [
    {
      "id": "gemini-1.5-flash",
      "provider": "google",
      "profile": ":pocketmodel-core"
    },
    {
      "id": "llama-3.1-8b-instant",
      "provider": "groq",
      "profile": ":pocketmodel-fast"
    },
    {
      "id": "deepseek/deepseek-chat",
      "provider": "openrouter",
      "profile": ":pocketmodel-brain"
    },
    {
      "id": "mistral-large",
      "provider": "github",
      "profile": ":pocketmodel-anchor"
    }
  ],
  "agents": {
    "defaults": {
      "model": {
        "primary": "gemini-1.5-flash",
        "fallbacks": [
          "llama-3.1-8b-instant",
          "deepseek/deepseek-chat",
          "mistral-large"
        ]
      }
    }
  }
}
```

---

## Required Keys

Add these directly to your `.env` file:

```bash
GEMINI_API_KEY=...
GROQ_API_KEY=...
OPENROUTER_API_KEY=...
GITHUB_TOKEN=...
```

---

## Why this is better for Founding 10

*   **Zero Latency:** No local proxy middleware.
*   **Simple Deployment:** One file to copy/paste.
*   **Robust:** The agent core handles the retry logic natively.
