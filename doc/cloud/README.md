# ☁️ Running PocketAgent in the Cloud (via GitHub Actions)

This guide shows you how to deploy PocketAgent to a VPS using **GitHub Actions**. This is often called "CI/CD" — you push code to GitHub, and it automatically updates your server.

no `.env` files to manage manually!

## 📋 Requirements

- **Server:** Ubuntu 22.04 / Debian 12
    - **RAM:** 4GB minimum.
    - **Storage:** 50GB minimum.
- **GitHub:** A copy (fork or clone) of this repository.

## 🚀 Step-by-Step Guide

### 1. Prepare Your Server

You need to do this only **once**.

SSH into your server:
```bash
ssh root@<YOUR_SERVER_IP>
```

Install **Docker** and **Git**:
```bash
apt update && apt upgrade -y
apt install -y git curl
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

**Generate an SSH Keypair for GitHub:**
We need to let GitHub access your server securely.
```bash
ssh-keygen -t ed25519 -f ~/.ssh/pocket_deploy -N ""
cat ~/.ssh/pocket_deploy.pub >> ~/.ssh/authorized_keys
```

Copy the **Private Key** (we'll need it in a second):
```bash
cat ~/.ssh/pocket_deploy
# Copy the entire block starting with -----BEGIN OPENSSH PRIVATE KEY-----
```

### 2. Configure GitHub Secrets

Go to your repository on GitHub:
1.  **Settings** → **Secrets and variables** → **Actions**.
2.  Click **New repository secret**.

Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `SERVER_HOST` | Your server's IP address (e.g. `123.45.67.89`) |
| `SERVER_USER` | `root` (or your sudo user) |
| `SSH_PRIVATE_KEY` | Paste the private key you copied in Step 1. |
| `OPENCLAW_GATEWAY_TOKEN` | Run `openssl rand -hex 32` locally and paste the result. |
| `TELEGRAM_BOT_TOKEN` | (Optional) Your Telegram bot token. |

### 3. Deploy!

Just push to the `main` branch.

```bash
git add .
git commit -m "Configure cloud deployment"
git push origin main
```

Go to the **Actions** tab in your GitHub repo to watch the deployment happen.

---

## 🔧 Adding LLM Keys (Repository Secrets)

We **do not** use `.env` files on the server. We use **GitHub Secrets**.

When you need to add an API Key (like `OPENAI_API_KEY`):

1.  Go to **GitHub Repo Settings** → **Secrets and variables** → **Actions**.
2.  Click **New repository secret**.
3.  Name: `OPENAI_API_KEY`
4.  Value: `sk-...` (your actual key)

Then, tell the deploy script to use it by editing `.github/workflows/deploy.yml`:

```yaml
# Add a line for your new key:
[ -n "${{ secrets.OPENAI_API_KEY }}" ] && echo "OPENAI_API_KEY=${{ secrets.OPENAI_API_KEY }}" >> .env
```

Commit and push. GitHub will securely inject that key into the server's environment during the next deploy.

---

### 4. Manage & Monitor (SSH)

Even though GitHub handles the updates and secrets, you still "own" the server. You can SSH in from your local terminal anytime to check on things.

**Connect:**
```bash
ssh root@<YOUR_SERVER_IP>
```

**Check Logs:**
```bash
cd /opt/agent
docker compose logs -f
```

**Restart Manually:**
```bash
docker compose restart
```

This gives you the best of both worlds: **Automated secrets management** via GitHub, and **Full Control** via your local terminal.
