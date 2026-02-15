# ☁️ Running PocketAgent in the Cloud

Deploying your agent to a cloud server (VPS) gives it a permanent home where it can run 24/7.

We recommend a simple **Manual Setup** to get started in minutes.

---

## 🚀 Quick Start (Manual Setup)

This is the stress-free way. You log in, clone the code, and run it.

### 1. Clone the Repo
First, clone the official repository to your local machine:

```bash
git clone https://github.com/PocketAgentNetwork/pocket-agent.git
cd pocket-agent
```

### 2. Define the Sovereign Soul
Don't just "configure"—architect your agent. This is where you establish its sovereignty and intelligence. We have already pre-loaded your workspace with a professional-grade foundation:

- **`workspace/IDENTITY.md`**: Your agent's unique ID, emoji, and name.
- **`workspace/SOUL.md`**: The Constitution. This is the "brain" you've given permission to self-evolve.
- **`workspace/USER.md`**: Sovereignty starts with you. Define your goals here.
- **`workspace/AGENTS.md`**: The orchestrator's map. It now links to your **Pocket Pioneer** and the full suite of 11 professional skills.
- **`workspace/skills/`**: A library of deep procedural wisdom (Engineer, Cloud-Master, Security-Guard) that acts as the agent's professional training.


### 3. Get a Google Cloud Server (VPS)
We recommend Google Cloud for reliability and free tier options.

1.  Go to the **[Google Cloud Console](https://console.cloud.google.com/compute/instances)**.
2.  Click **Create Instance**.
3.  **Name:** `pocket-agent`
4.  **Region:** Choose one close to you (e.g., `us-central1`).
5.  **Machine Type:** `e2-medium` (2 vCPU, 4GB memory) — minimum recommended.
6.  **Boot Disk:** Change to **Ubuntu 22.04 LTS** (x86/64). Set size to **50GB**.
7.  **Firewall:** Check **Allow HTTP traffic** and **Allow HTTPS traffic**.
8.  Click **Create**.
9.  Copy the **External IP** address once it's ready.

### 3. Add Your SSH Key (Important!)
Google Cloud needs your public key to let you log in.

1.  On your **local machine**, view your public key:
    ```bash
    cat ~/.ssh/id_ed25519.pub
    # If that file doesn't exist, generate one: ssh-keygen -t ed25519
    ```
2.  Copy the output (starts with `ssh-ed25519...`).
3.  In Google Cloud Console, go to **Compute Engine** -> **Metadata** -> **SSH Keys**.
4.  Click **Edit** -> **Add Item**.
5.  Paste your key and click **Save**.

### 4. Connect to Your Server
Open your terminal and SSH into your new server:
```bash
ssh <YOUR_GCP_USERNAME>@<YOUR_EXTERNAL_IP>
```
*(You may need to set up SSH keys in the Metadata section if not using gcloud CLI)*

### 5. Install Docker & Git
Run this command on your server to install the necessary tools:
```bash
apt update && apt upgrade -y
apt install -y git curl
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### 6. Setup Automated Deployment (GitHub Actions)
Instead of cloning manually, we'll let GitHub deploy for us automatically.

**A. Generate a Deployment Key (On Server)**
Still in your SSH session, run:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/pocket_deploy -N ""
cat ~/.ssh/pocket_deploy.pub >> ~/.ssh/authorized_keys
cat ~/.ssh/pocket_deploy
```
Copy the **Private Key** block (starting with `-----BEGIN OPENSSH PRIVATE KEY-----`).

**B. Add Secrets to GitHub**
1.  Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**.
2.  Click **New repository secret**.
3.  Add these secrets:

| Name | Value |
|------|-------|
| `SERVER_HOST` | Your server's External IP |
| `SERVER_USER` | Your username (e.g. `root` or `gcp_user`) |
| `SSH_PRIVATE_KEY` | Paste the Private Key you just copied |
| `OPENCLAW_GATEWAY_TOKEN` | A random string (e.g. run `openssl rand -hex 32`) |
| **PocketModel Keys** | *(Required for AI)* |
| `GEMINI_API_KEY` | Get from Google AI Studio |
| `GROQ_API_KEY` | Get from Groq Console |
| `OPENROUTER_API_KEY` | Get from OpenRouter |
| `GITHUB_TOKEN` | A classic PAT (for Mistral access) |

**C. Deploy!**
Now, just push your code to the `main` branch on GitHub:
```bash
git add .
git commit -m "Setup cloud deployment"
git push origin main
```

Go to the **Actions** tab in your GitHub repo to watch it deploy! 🚀

---

## 🔧 Managing Your Agent

Even though GitHub handles updates, you can check logs anytime:
```bash
# Connect
ssh <YOUR_GCP_USERNAME>@<YOUR_EXTERNAL_IP>

# View Logs
cd /opt/agent
docker compose logs -f
```
