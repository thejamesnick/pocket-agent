FROM node:22-bookworm

# ── System Tools ──
# The agent's headless Mac Mini. Full dev environment.
# It should be able to install anything, SSH anywhere, build anything.
RUN apt-get update && apt-get install -y \
    # ── Core Utilities ──
    socat \
    curl \
    wget \
    git \
    jq \
    unzip \
    zip \
    tree \
    htop \
    less \
    file \
    nano \
    vim \
    sudo \
    cron \
    # ── SSH (client — so the agent can connect to other machines) ──
    openssh-client \
    # ── Build Tools (compile native packages, Rust crates, etc.) ──
    build-essential \
    pkg-config \
    libssl-dev \
    cmake \
    # ── Python ──
    python3 \
    python3-pip \
    python3-venv \
    # ── Networking ──
    dnsutils \
    iputils-ping \
    net-tools \
    ca-certificates \
    # ── File Sync & Transfer ──
    rsync \
    # ── Database ──
    sqlite3 \
    # ── Archives ──
    xz-utils \
    bzip2 \
    tar \
    gzip \
    # ── Security / Crypto ──
    gnupg \
    # ── Terminal Multiplexer (persistent sessions) ──
    tmux \
    screen \
    # ── Browser Support (Chrome/Puppeteer) ──
    # Essential libs for headless browser + fonts
    libnss3 \
    libxss1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgbm-dev \
    fonts-liberation \
    libayatana-appindicator3-1 \
    lsb-release \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# ── Install Google Chrome Stable (Latest) ──
# Because Puppeteer bundled Chromium can be finicky in Docker sometimes.
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# ── Allow the node user to sudo (install packages on the fly) ──
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ── Clone and build OpenClaw from source ──
WORKDIR /app
RUN git clone https://github.com/openclaw/openclaw.git . && \
    corepack enable && \
    pnpm install --frozen-lockfile && \
    pnpm build && \
    pnpm ui:install && \
    pnpm ui:build

# ── Home directory setup ──
# The agent's home dir is a persistent volume, so anything it installs
# or saves there (tools, keys, configs) survives container restarts.
ENV HOME=/home/node
RUN mkdir -p /home/node/.openclaw \
    /home/node/.local/bin \
    /home/node/.ssh \
    /home/node/.config \
    /home/node/files \
    && chmod 700 /home/node/.ssh \
    && chown -R node:node /home/node

# PATH: include ~/.local/bin and ~/.cargo/bin so installed tools persist
ENV PATH="/home/node/.local/bin:/home/node/.cargo/bin:${PATH}"

# ── Startup script ──
# Runs on every container boot. Sources a user-defined script if it exists,
# so the agent can add its own boot commands.
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# ── Bake workspace into image (fallback if no volume mount) ──
COPY workspace /home/node/.openclaw/workspace

# ── Seed workspace logic (for entrypoint.sh) ──
# If the user mounts an empty volume at /home/node/.openclaw/workspace,
# entrypoint.sh needs a source to copy from.
RUN mkdir -p /app/workspace_init && cp -r workspace/* /app/workspace_init/

# ── Runtime ──
EXPOSE 18789
ENV NODE_ENV=production

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["node", "dist/index.js", "gateway", "--workspace", "/home/node/.openclaw/workspace", "--bind", "lan", "--port", "18789", "--allow-unconfigured"]
