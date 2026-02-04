#!/bin/bash

#===============================================================================
# FUTILITY'S — INSTALLATION WIZARD
#===============================================================================
#
# This script will set up your entire Futility's SSOT system.
# Run it on a fresh Ubuntu 22.04 DigitalOcean droplet.
#
# BEFORE RUNNING THIS SCRIPT, YOU NEED:
#   1. A DigitalOcean droplet running Ubuntu 22.04
#   2. SSH access to that droplet (you're running this on it)
#   3. A GitHub account
#   4. A domain name (optional, can use IP address)
#
# USAGE:
#   curl -sSL https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/install.sh | bash
#   OR
#   wget -qO- https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/install.sh | bash
#   OR
#   bash install.sh
#
#===============================================================================

set -e  # Exit on error

#===============================================================================
# COLORS AND FORMATTING
#===============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶${NC} ${BOLD}$1${NC}"
}

print_info() {
    echo -e "${CYAN}  ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}  ⚠${NC} $1"
}

print_error() {
    echo -e "${RED}  ✗${NC} $1"
}

print_success() {
    echo -e "${GREEN}  ✓${NC} $1"
}

press_enter() {
    echo ""
    echo -e "${YELLOW}Press ENTER to continue...${NC}"
    read -r
}

ask_yes_no() {
    while true; do
        echo -e "${CYAN}$1 (y/n):${NC} "
        read -r yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

ask_input() {
    echo -e "${CYAN}$1:${NC} "
    read -r REPLY
    echo "$REPLY"
}

#===============================================================================
# CONFIGURATION VARIABLES (will be set during wizard)
#===============================================================================

CONFIG_FILE="$HOME/.futilitys_config"
APP_DIR="$HOME/futilitys"
SPEC_DIR="$HOME/futilitys-spec"
DATA_DIR="/var/lib/futilitys"

# Load existing config if present
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

save_config() {
    cat > "$CONFIG_FILE" << EOF
DOMAIN="$DOMAIN"
GITHUB_REPO="$GITHUB_REPO"
USERNAME="$USERNAME"
PIN="$PIN"
ANTHROPIC_KEY="$ANTHROPIC_KEY"
SETUP_PHASE="$SETUP_PHASE"
EOF
    chmod 600 "$CONFIG_FILE"
}

#===============================================================================
# PREREQUISITE CHECKS
#===============================================================================

check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_warning "You're running as root. We'll create a non-root user."
        return 0
    else
        print_info "Running as: $(whoami)"
        return 1
    fi
}

check_ubuntu() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            print_success "Ubuntu detected: $VERSION"
            return 0
        fi
    fi
    print_error "This script requires Ubuntu. Detected: $ID"
    exit 1
}

check_internet() {
    if ping -c 1 google.com &> /dev/null; then
        print_success "Internet connection OK"
        return 0
    else
        print_error "No internet connection. Please check your network."
        exit 1
    fi
}

#===============================================================================
# PHASE 1: SYSTEM SETUP
#===============================================================================

phase1_system_setup() {
    print_header "PHASE 1: SYSTEM SETUP"

    print_step "Updating system packages..."
    apt update
    DEBIAN_FRONTEND=noninteractive apt upgrade -y
    print_success "System updated"

    print_step "Installing essential packages..."
    apt install -y \
        curl \
        wget \
        git \
        sqlite3 \
        ufw \
        fail2ban \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release
    print_success "Essential packages installed"

    print_step "Setting timezone..."
    timedatectl set-timezone America/New_York
    print_success "Timezone set to America/New_York"

    print_step "Configuring firewall..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow http
    ufw allow https
    ufw --force enable
    print_success "Firewall configured (SSH, HTTP, HTTPS allowed)"

    SETUP_PHASE=1
    save_config
    print_success "Phase 1 complete!"
}

#===============================================================================
# PHASE 2: CREATE NON-ROOT USER
#===============================================================================

phase2_create_user() {
    print_header "PHASE 2: CREATE NON-ROOT USER"

    if [ "$EUID" -ne 0 ]; then
        print_info "Already running as non-root user: $(whoami)"
        USERNAME=$(whoami)
        save_config
        SETUP_PHASE=2
        save_config
        return 0
    fi

    echo ""
    USERNAME=$(ask_input "Enter username for the new admin user (e.g., gondor)")

    if id "$USERNAME" &>/dev/null; then
        print_warning "User $USERNAME already exists"
    else
        print_step "Creating user: $USERNAME"
        adduser --gecos "" "$USERNAME"
        usermod -aG sudo "$USERNAME"
        print_success "User $USERNAME created with sudo access"
    fi

    # Copy SSH keys if they exist
    if [ -f "$HOME/.ssh/authorized_keys" ]; then
        print_step "Copying SSH keys to new user..."
        mkdir -p "/home/$USERNAME/.ssh"
        cp "$HOME/.ssh/authorized_keys" "/home/$USERNAME/.ssh/"
        chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
        chmod 700 "/home/$USERNAME/.ssh"
        chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
        print_success "SSH keys copied"
    fi

    SETUP_PHASE=2
    save_config

    # Copy config to new user
    cp "$CONFIG_FILE" "/home/$USERNAME/.futilitys_config"
    chown "$USERNAME:$USERNAME" "/home/$USERNAME/.futilitys_config"

    print_success "Phase 2 complete!"
    echo ""
    print_warning "IMPORTANT: You should now:"
    echo "  1. Open a NEW terminal"
    echo "  2. SSH in as: ssh $USERNAME@YOUR_IP"
    echo "  3. Run this script again: bash install.sh"
    echo ""
    print_info "The script will continue from where it left off."
    exit 0
}

#===============================================================================
# PHASE 3: INSTALL NODE.JS
#===============================================================================

phase3_install_node() {
    print_header "PHASE 3: INSTALL NODE.JS"

    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_info "Node.js already installed: $NODE_VERSION"
        if [[ "$NODE_VERSION" == v20* ]] || [[ "$NODE_VERSION" == v21* ]] || [[ "$NODE_VERSION" == v22* ]]; then
            print_success "Node.js version is compatible"
            SETUP_PHASE=3
            save_config
            return 0
        else
            print_warning "Node.js version is old, upgrading..."
        fi
    fi

    print_step "Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs

    print_step "Installing PM2 (process manager)..."
    sudo npm install -g pm2

    print_success "Node.js $(node --version) installed"
    print_success "PM2 $(pm2 --version) installed"

    SETUP_PHASE=3
    save_config
    print_success "Phase 3 complete!"
}

#===============================================================================
# PHASE 4: INSTALL CADDY (WEB SERVER)
#===============================================================================

phase4_install_caddy() {
    print_header "PHASE 4: INSTALL CADDY (WEB SERVER)"

    if command -v caddy &> /dev/null; then
        print_info "Caddy already installed: $(caddy version)"
        SETUP_PHASE=4
        save_config
        return 0
    fi

    print_step "Installing Caddy..."
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg 2>/dev/null || true
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install -y caddy

    print_success "Caddy installed"

    SETUP_PHASE=4
    save_config
    print_success "Phase 4 complete!"
}

#===============================================================================
# PHASE 5: INSTALL GITHUB CLI
#===============================================================================

phase5_install_gh() {
    print_header "PHASE 5: INSTALL GITHUB CLI"

    if command -v gh &> /dev/null; then
        print_info "GitHub CLI already installed: $(gh --version | head -1)"
    else
        print_step "Installing GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
        print_success "GitHub CLI installed"
    fi

    # Check if already authenticated
    if gh auth status &>/dev/null; then
        print_success "GitHub CLI already authenticated"
    else
        print_step "Authenticating GitHub CLI..."
        echo ""
        print_info "This will open an interactive login process."
        print_info "Select: GitHub.com → HTTPS → Yes → Login with web browser"
        echo ""
        press_enter
        gh auth login
        print_success "GitHub CLI authenticated"
    fi

    SETUP_PHASE=5
    save_config
    print_success "Phase 5 complete!"
}

#===============================================================================
# PHASE 6: GENERATE SSH KEY FOR GITHUB
#===============================================================================

phase6_ssh_key() {
    print_header "PHASE 6: GENERATE DEPLOY KEY"

    DEPLOY_KEY="$HOME/.ssh/futilitys_deploy_key"

    if [ -f "$DEPLOY_KEY" ]; then
        print_info "Deploy key already exists"
    else
        print_step "Generating deploy key..."
        ssh-keygen -t ed25519 -f "$DEPLOY_KEY" -N "" -C "futilitys-deploy-key"
        print_success "Deploy key generated"
    fi

    echo ""
    print_info "Your deploy key PUBLIC key is:"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    cat "${DEPLOY_KEY}.pub"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    print_warning "MANUAL STEP REQUIRED:"
    echo ""
    echo "  1. Copy the key above"
    echo "  2. Go to your GitHub repository"
    echo "  3. Click: Settings → Deploy keys → Add deploy key"
    echo "  4. Title: 'Futilitys Server'"
    echo "  5. Paste the key"
    echo "  6. CHECK 'Allow write access'"
    echo "  7. Click 'Add key'"
    echo ""

    if ask_yes_no "Have you added the deploy key to GitHub?"; then
        print_success "Deploy key configured"
    else
        print_warning "You'll need to do this before the script can clone your repo"
    fi

    # Configure SSH to use this key for GitHub
    mkdir -p "$HOME/.ssh"
    cat >> "$HOME/.ssh/config" << EOF

Host github.com
    HostName github.com
    User git
    IdentityFile $DEPLOY_KEY
    IdentitiesOnly yes
EOF

    chmod 600 "$HOME/.ssh/config"

    SETUP_PHASE=6
    save_config
    print_success "Phase 6 complete!"
}

#===============================================================================
# PHASE 7: COLLECT CONFIGURATION
#===============================================================================

phase7_collect_config() {
    print_header "PHASE 7: CONFIGURATION"

    echo ""
    print_info "I need a few pieces of information to set up your system."
    echo ""

    # Domain
    if [ -z "$DOMAIN" ]; then
        echo ""
        print_info "Enter your domain name (e.g., futilitys.com)"
        print_info "Or press ENTER to use this server's IP address"
        DOMAIN=$(ask_input "Domain")
        if [ -z "$DOMAIN" ]; then
            DOMAIN=$(curl -s ifconfig.me)
            print_info "Using IP address: $DOMAIN"
        fi
    else
        print_info "Domain: $DOMAIN"
        if ask_yes_no "Keep this domain?"; then
            :
        else
            DOMAIN=$(ask_input "Enter new domain")
        fi
    fi

    # GitHub repo
    if [ -z "$GITHUB_REPO" ]; then
        echo ""
        print_info "Enter your GitHub repository (e.g., username/repo-name)"
        GITHUB_REPO=$(ask_input "GitHub repo")
    else
        print_info "GitHub repo: $GITHUB_REPO"
        if ! ask_yes_no "Keep this repo?"; then
            GITHUB_REPO=$(ask_input "Enter new repo")
        fi
    fi

    # PIN
    if [ -z "$PIN" ]; then
        echo ""
        print_info "Choose a PIN for accessing the web interface"
        print_info "This should be 4-8 digits that you'll remember"
        PIN=$(ask_input "PIN")
    else
        print_info "PIN is already set"
        if ask_yes_no "Keep existing PIN?"; then
            :
        else
            PIN=$(ask_input "Enter new PIN")
        fi
    fi

    # Anthropic API key (optional for now)
    if [ -z "$ANTHROPIC_KEY" ]; then
        echo ""
        print_info "Enter your Anthropic API key (for Claude AI features)"
        print_info "Press ENTER to skip for now (you can add it later)"
        ANTHROPIC_KEY=$(ask_input "Anthropic API key")
    fi

    save_config

    echo ""
    print_success "Configuration saved!"
    echo ""
    echo "  Domain:      $DOMAIN"
    echo "  GitHub:      $GITHUB_REPO"
    echo "  PIN:         [hidden]"
    echo "  API Key:     ${ANTHROPIC_KEY:+[set]}${ANTHROPIC_KEY:-[not set]}"
    echo ""

    SETUP_PHASE=7
    save_config
    print_success "Phase 7 complete!"
}

#===============================================================================
# PHASE 8: CLONE REPOSITORY
#===============================================================================

phase8_clone_repo() {
    print_header "PHASE 8: CLONE REPOSITORY"

    if [ -d "$SPEC_DIR/.git" ]; then
        print_info "Repository already cloned at $SPEC_DIR"
        cd "$SPEC_DIR"
        print_step "Pulling latest changes..."
        git pull || print_warning "Could not pull (may need deploy key)"
    else
        print_step "Cloning repository..."

        # Test SSH connection first
        print_info "Testing GitHub SSH connection..."
        if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
            print_success "GitHub SSH connection OK"
        else
            print_warning "GitHub SSH may not be configured. Trying anyway..."
        fi

        git clone "git@github.com:${GITHUB_REPO}.git" "$SPEC_DIR" || {
            print_error "Failed to clone. Make sure:"
            echo "  1. The deploy key is added to GitHub"
            echo "  2. The repository name is correct: $GITHUB_REPO"
            echo "  3. 'Allow write access' is checked"
            return 1
        }

        print_success "Repository cloned to $SPEC_DIR"
    fi

    # Configure git
    cd "$SPEC_DIR"
    git config user.name "Futilitys Bot"
    git config user.email "bot@futilitys.local"

    SETUP_PHASE=8
    save_config
    print_success "Phase 8 complete!"
}

#===============================================================================
# PHASE 9: CREATE APPLICATION
#===============================================================================

phase9_create_app() {
    print_header "PHASE 9: CREATE APPLICATION"

    print_step "Creating application directory..."
    mkdir -p "$APP_DIR"
    cd "$APP_DIR"

    print_step "Creating data directories..."
    sudo mkdir -p "$DATA_DIR/artifacts/documents"
    sudo mkdir -p "$DATA_DIR/artifacts/photos"
    sudo mkdir -p "$DATA_DIR/data"
    sudo chown -R "$USER:$USER" "$DATA_DIR"

    print_step "Initializing Node.js project..."
    if [ ! -f "package.json" ]; then
        cat > package.json << 'EOF'
{
  "name": "futilitys",
  "version": "1.0.0",
  "description": "Futility's SSOT Engine",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "body-parser": "^1.20.2",
    "multer": "^1.4.5-lts.1",
    "better-sqlite3": "^9.4.3",
    "cookie-parser": "^1.4.6"
  }
}
EOF
    fi

    print_step "Installing dependencies..."
    npm install

    print_step "Creating server application..."
    cat > server.js << 'SERVEREOF'
const express = require('express');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');
const Database = require('better-sqlite3');

//=============================================================================
// CONFIGURATION
//=============================================================================

const CONFIG = {
    PORT: process.env.PORT || 3000,
    PIN: process.env.PIN || '1234',
    SPEC_DIR: process.env.SPEC_DIR || path.join(process.env.HOME, 'futilitys-spec'),
    DATA_DIR: process.env.DATA_DIR || '/var/lib/futilitys',
    COOKIE_NAME: 'futilitys_auth',
    COOKIE_MAX_AGE: 7 * 24 * 60 * 60 * 1000, // 7 days
};

//=============================================================================
// DATABASE SETUP
//=============================================================================

const db = new Database(path.join(CONFIG.DATA_DIR, 'data', 'futilitys.db'));

db.exec(`
    CREATE TABLE IF NOT EXISTS captures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        capture_id TEXT UNIQUE NOT NULL,
        content TEXT NOT NULL,
        input_type TEXT DEFAULT 'chat',
        file_path TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        git_committed INTEGER DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS feedback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        capture_id TEXT,
        rating INTEGER,
        comment TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        details TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
`);

function logAudit(action, details) {
    db.prepare('INSERT INTO audit_log (action, details) VALUES (?, ?)').run(action, JSON.stringify(details));
}

//=============================================================================
// EXPRESS SETUP
//=============================================================================

const app = express();

app.use(bodyParser.urlencoded({ extended: true, limit: '50mb' }));
app.use(bodyParser.json({ limit: '50mb' }));
app.use(cookieParser());

// File upload setup
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const type = file.mimetype.startsWith('image/') ? 'photos' : 'documents';
        const dir = path.join(CONFIG.DATA_DIR, 'artifacts', type);
        fs.mkdirSync(dir, { recursive: true });
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        cb(null, `${timestamp}-${file.originalname}`);
    }
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } }); // 50MB limit

//=============================================================================
// AUTHENTICATION
//=============================================================================

function authMiddleware(req, res, next) {
    if (req.path === '/login' || req.path === '/auth' || req.path.startsWith('/static')) {
        return next();
    }

    const authCookie = req.cookies[CONFIG.COOKIE_NAME];
    if (authCookie === CONFIG.PIN) {
        return next();
    }

    res.redirect('/login');
}

app.use(authMiddleware);

//=============================================================================
// STYLES (Mobile-first, big touch targets for dirty hands)
//=============================================================================

const STYLES = `
    * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        max-width: 900px;
        margin: 0 auto;
        padding: 15px;
        background: #0d1117;
        color: #c9d1d9;
        line-height: 1.6;
        font-size: 16px;
    }
    h1 { color: #58a6ff; font-size: 24px; margin: 10px 0; }
    h2 { color: #58a6ff; font-size: 20px; }
    a { color: #58a6ff; }
    .container {
        background: #161b22;
        border: 1px solid #30363d;
        border-radius: 12px;
        padding: 20px;
        margin: 15px 0;
    }
    input, textarea, select {
        width: 100%;
        padding: 16px;
        margin: 8px 0;
        background: #0d1117;
        border: 2px solid #30363d;
        border-radius: 12px;
        color: #c9d1d9;
        font-family: inherit;
        font-size: 18px;
    }
    input:focus, textarea:focus { border-color: #58a6ff; outline: none; }
    textarea { min-height: 120px; resize: vertical; }

    /* Big touch-friendly buttons */
    button, .btn {
        background: #238636;
        color: white;
        border: none;
        padding: 18px 32px;
        border-radius: 12px;
        cursor: pointer;
        font-size: 18px;
        font-weight: 600;
        text-decoration: none;
        display: inline-block;
        margin: 6px;
        min-height: 56px;
        touch-action: manipulation;
    }
    button:hover, .btn:hover { background: #2ea043; }
    button:active, .btn:active { transform: scale(0.98); }
    .btn-secondary { background: #30363d; }
    .btn-secondary:hover { background: #484f58; }
    .btn-large {
        width: 100%;
        padding: 24px;
        font-size: 22px;
        margin: 10px 0;
        min-height: 80px;
    }

    /* Action buttons - voice & photo */
    .action-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 15px;
        margin: 20px 0;
    }
    .action-btn {
        background: linear-gradient(135deg, #238636 0%, #2ea043 100%);
        border-radius: 16px;
        padding: 30px 20px;
        text-align: center;
        min-height: 120px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
    }
    .action-btn.photo { background: linear-gradient(135deg, #1f6feb 0%, #388bfd 100%); }
    .action-btn .icon { font-size: 48px; margin-bottom: 10px; }
    .action-btn .label { font-size: 18px; font-weight: 600; }

    /* Voice recording states */
    .btn-voice { background: #238636; }
    .btn-voice.recording {
        background: #f85149;
        animation: pulse 1s infinite;
    }
    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.7; }
    }

    .success { color: #3fb950; }
    .error { color: #f85149; }
    .warning { color: #d29922; }
    .info { color: #58a6ff; }
    .meta { color: #8b949e; font-size: 14px; }

    .capture-item {
        border-left: 4px solid #30363d;
        padding: 15px;
        margin: 12px 0;
        background: #0d1117;
        border-radius: 0 12px 12px 0;
    }
    .feedback-btns { margin-top: 12px; display: flex; gap: 10px; }
    .feedback-btns button {
        padding: 12px 24px;
        font-size: 24px;
        background: transparent;
        border: 2px solid #30363d;
        min-height: 50px;
        flex: 1;
    }
    .feedback-btns button:hover { background: #30363d; }
    .feedback-btns button.selected-up { background: #238636; border-color: #238636; }
    .feedback-btns button.selected-down { background: #f85149; border-color: #f85149; }

    nav {
        display: flex;
        gap: 5px;
        margin-bottom: 15px;
        padding-bottom: 15px;
        border-bottom: 1px solid #30363d;
        flex-wrap: wrap;
    }
    nav a {
        padding: 12px 16px;
        background: #21262d;
        border-radius: 8px;
        text-decoration: none;
        font-size: 14px;
    }
    nav a:hover { background: #30363d; }

    .stat-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 10px;
    }
    .stat-box {
        background: #0d1117;
        padding: 20px 15px;
        border-radius: 12px;
        text-align: center;
    }
    .stat-number { font-size: 28px; font-weight: bold; color: #58a6ff; }
    .stat-label { font-size: 12px; color: #8b949e; margin-top: 5px; }

    /* Camera/file input styling */
    .file-input-wrapper {
        position: relative;
        overflow: hidden;
        display: block;
    }
    .file-input-wrapper input[type=file] {
        position: absolute;
        left: 0;
        top: 0;
        opacity: 0;
        width: 100%;
        height: 100%;
        cursor: pointer;
    }

    /* Transcript preview */
    .transcript-preview {
        background: #0d1117;
        border: 2px dashed #30363d;
        border-radius: 12px;
        padding: 20px;
        margin: 15px 0;
        min-height: 100px;
        font-size: 18px;
        line-height: 1.5;
    }
    .transcript-preview.has-content { border-style: solid; border-color: #238636; }
    .transcript-preview .placeholder { color: #6e7681; font-style: italic; }

    @media (max-width: 500px) {
        .stat-grid { grid-template-columns: repeat(3, 1fr); }
        .action-grid { grid-template-columns: 1fr; }
        .action-btn { min-height: 100px; }
    }
`;

//=============================================================================
// ROUTES: AUTH
//=============================================================================

app.get('/login', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Futility's - Login</title>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>${STYLES}</style>
        </head>
        <body>
            <div class="container" style="max-width: 400px; margin: 100px auto; text-align: center;">
                <h1>Futility's</h1>
                <p class="meta">Single Source of Truth Engine</p>
                <form method="POST" action="/auth">
                    <input type="password" name="pin" placeholder="Enter PIN" autofocus />
                    <button type="submit">Enter</button>
                </form>
            </div>
        </body>
        </html>
    `);
});

app.post('/auth', (req, res) => {
    if (req.body.pin === CONFIG.PIN) {
        res.cookie(CONFIG.COOKIE_NAME, CONFIG.PIN, {
            maxAge: CONFIG.COOKIE_MAX_AGE,
            httpOnly: true,
            sameSite: 'strict'
        });
        logAudit('login', { success: true });
        res.redirect('/');
    } else {
        logAudit('login', { success: false });
        res.redirect('/login?error=1');
    }
});

app.get('/logout', (req, res) => {
    res.clearCookie(CONFIG.COOKIE_NAME);
    res.redirect('/login');
});

//=============================================================================
// ROUTES: MAIN
//=============================================================================

app.get('/', (req, res) => {
    const stats = {
        captures: db.prepare('SELECT COUNT(*) as count FROM captures').get().count,
        today: db.prepare("SELECT COUNT(*) as count FROM captures WHERE date(created_at) = date('now')").get().count,
        feedback: db.prepare('SELECT COUNT(*) as count FROM feedback').get().count,
    };

    const recentCaptures = db.prepare(`
        SELECT * FROM captures ORDER BY created_at DESC LIMIT 3
    `).all();

    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Futility's</title>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <style>${STYLES}</style>
        </head>
        <body>
            <nav>
                <a href="/">Home</a>
                <a href="/voice">Voice</a>
                <a href="/photo">Photo</a>
                <a href="/browse">Browse</a>
                <a href="/logout">Out</a>
            </nav>

            <h1>Futility's</h1>

            <!-- BIG ACTION BUTTONS - The main event -->
            <div class="action-grid">
                <a href="/voice" class="action-btn" style="text-decoration:none; color:white;">
                    <div class="icon">🎤</div>
                    <div class="label">SPEAK</div>
                </a>
                <a href="/photo" class="action-btn photo" style="text-decoration:none; color:white;">
                    <div class="icon">📷</div>
                    <div class="label">PHOTO</div>
                </a>
            </div>

            <!-- Stats -->
            <div class="container">
                <div class="stat-grid">
                    <div class="stat-box">
                        <div class="stat-number">${stats.captures}</div>
                        <div class="stat-label">Total</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-number">${stats.today}</div>
                        <div class="stat-label">Today</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-number">${stats.feedback}</div>
                        <div class="stat-label">Feedback</div>
                    </div>
                </div>
            </div>

            <!-- Quick type option -->
            <div class="container">
                <form method="POST" action="/capture">
                    <textarea name="content" placeholder="Or type here..." rows="2"></textarea>
                    <button type="submit" class="btn-large">Save Note</button>
                </form>
            </div>

            <!-- Recent captures -->
            ${recentCaptures.length > 0 ? \`
            <div class="container">
                <h2>Recent</h2>
                \${recentCaptures.map(c => \`
                    <div class="capture-item">
                        <div class="meta">\${c.input_type} · \${new Date(c.created_at).toLocaleString()}</div>
                        <p>\${escapeHtml(c.content.substring(0, 100))}\${c.content.length > 100 ? '...' : ''}</p>
                        <div class="feedback-btns">
                            <button onclick="feedback('\${c.capture_id}', 1, this)">👍</button>
                            <button onclick="feedback('\${c.capture_id}', -1, this)">👎</button>
                        </div>
                    </div>
                \`).join('')}
            </div>
            \` : ''}

            <script>
                function feedback(captureId, rating, btn) {
                    fetch('/feedback', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ capture_id: captureId, rating })
                    }).then(() => {
                        btn.classList.add(rating > 0 ? 'selected-up' : 'selected-down');
                    });
                }
            </script>
        </body>
        </html>
    `);
});

//=============================================================================
// ROUTES: CAPTURE
//=============================================================================

app.get('/capture', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Futility's - Type Capture</title>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <style>${STYLES}</style>
        </head>
        <body>
            <nav>
                <a href="/">Home</a>
                <a href="/voice">Voice</a>
                <a href="/photo">Photo</a>
                <a href="/browse">Browse</a>
                <a href="/logout">Out</a>
            </nav>

            <h1>Type a Note</h1>

            <div class="container">
                <form method="POST" action="/capture">
                    <textarea name="content" rows="6" placeholder="What do you want to capture?"></textarea>

                    <select name="input_type">
                        <option value="note">Note</option>
                        <option value="observation">Observation</option>
                        <option value="question">Question</option>
                        <option value="procedure">Procedure</option>
                        <option value="issue">Issue / Problem</option>
                    </select>

                    <button type="submit" class="btn-large">Save</button>
                </form>
            </div>

            <div class="container">
                <p class="meta" style="text-align:center;">
                    Prefer talking? <a href="/voice">Use voice input</a>
                </p>
            </div>
        </body>
        </html>
    `);
});

app.post('/capture', (req, res) => {
    const { content, input_type = 'chat' } = req.body;

    if (!content || content.trim() === '') {
        return res.redirect('/capture?error=empty');
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const captureId = `CAP-${timestamp}`;

    // Save to database
    db.prepare(`
        INSERT INTO captures (capture_id, content, input_type) VALUES (?, ?, ?)
    `).run(captureId, content, input_type);

    // Save to git repo
    const capturesDir = path.join(CONFIG.SPEC_DIR, 'captures');
    fs.mkdirSync(capturesDir, { recursive: true });

    const filename = `${captureId}.txt`;
    const filepath = path.join(capturesDir, filename);
    const fileContent = `CAPTURE: ${captureId}
TYPE: ${input_type}
TIMESTAMP: ${new Date().toISOString()}

${content}
`;

    fs.writeFileSync(filepath, fileContent);

    // Git commit and push
    try {
        execSync(`git add "captures/${filename}"`, { cwd: CONFIG.SPEC_DIR });
        execSync(`git commit -m "Capture: ${captureId}"`, { cwd: CONFIG.SPEC_DIR });
        execSync('git push', { cwd: CONFIG.SPEC_DIR });

        db.prepare('UPDATE captures SET git_committed = 1 WHERE capture_id = ?').run(captureId);
        logAudit('capture', { captureId, input_type, git: true });

        res.redirect(`/success?id=${captureId}`);
    } catch (error) {
        logAudit('capture', { captureId, input_type, git: false, error: error.message });
        res.redirect(`/success?id=${captureId}&git=failed`);
    }
});

//=============================================================================
// ROUTES: VOICE INPUT (Web Speech API)
//=============================================================================

app.get('/voice', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Futility's - Voice Capture</title>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <style>${STYLES}</style>
        </head>
        <body>
            <nav>
                <a href="/">Home</a>
                <a href="/voice">Voice</a>
                <a href="/photo">Photo</a>
                <a href="/browse">Browse</a>
                <a href="/logout">Out</a>
            </nav>

            <h1>Voice Capture</h1>

            <div class="container">
                <button id="voiceBtn" class="btn-large btn-voice" onclick="toggleVoice()">
                    🎤 Tap to Talk
                </button>

                <div id="status" class="meta" style="text-align:center; margin: 15px 0;">
                    Tap the button and speak clearly
                </div>

                <form method="POST" action="/capture" id="voiceForm">
                    <div id="transcript" class="transcript-preview">
                        <span class="placeholder">Your words will appear here...</span>
                    </div>
                    <input type="hidden" name="content" id="contentField" />
                    <input type="hidden" name="input_type" value="voice" />
                    <button type="submit" class="btn-large" id="submitBtn" disabled>
                        Save Capture
                    </button>
                </form>
            </div>

            <div class="container">
                <p class="meta" style="text-align:center;">
                    Works best in Chrome or Safari on mobile.<br>
                    Speak clearly. Tap again to stop.
                </p>
            </div>

            <script>
                let recognition = null;
                let isRecording = false;
                let fullTranscript = '';

                // Check for Web Speech API support
                const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

                if (!SpeechRecognition) {
                    document.getElementById('status').innerHTML =
                        '<span class="error">Voice input not supported in this browser. Try Chrome or Safari.</span>';
                    document.getElementById('voiceBtn').disabled = true;
                    document.getElementById('voiceBtn').textContent = 'Not Supported';
                } else {
                    recognition = new SpeechRecognition();
                    recognition.continuous = true;
                    recognition.interimResults = true;
                    recognition.lang = 'en-US';

                    recognition.onresult = (event) => {
                        let interim = '';
                        let final = '';

                        for (let i = event.resultIndex; i < event.results.length; i++) {
                            const transcript = event.results[i][0].transcript;
                            if (event.results[i].isFinal) {
                                final += transcript + ' ';
                            } else {
                                interim += transcript;
                            }
                        }

                        if (final) {
                            fullTranscript += final;
                        }

                        const display = fullTranscript + '<span style="color:#6e7681">' + interim + '</span>';
                        document.getElementById('transcript').innerHTML = display || '<span class="placeholder">Your words will appear here...</span>';
                        document.getElementById('transcript').classList.toggle('has-content', fullTranscript.length > 0);

                        if (fullTranscript.trim()) {
                            document.getElementById('contentField').value = fullTranscript.trim();
                            document.getElementById('submitBtn').disabled = false;
                        }
                    };

                    recognition.onerror = (event) => {
                        console.error('Speech error:', event.error);
                        if (event.error === 'not-allowed') {
                            document.getElementById('status').innerHTML =
                                '<span class="error">Microphone access denied. Check browser permissions.</span>';
                        } else {
                            document.getElementById('status').innerHTML =
                                '<span class="warning">Error: ' + event.error + '. Try again.</span>';
                        }
                        stopRecording();
                    };

                    recognition.onend = () => {
                        if (isRecording) {
                            // Restart if still supposed to be recording
                            recognition.start();
                        }
                    };
                }

                function toggleVoice() {
                    if (isRecording) {
                        stopRecording();
                    } else {
                        startRecording();
                    }
                }

                function startRecording() {
                    if (!recognition) return;

                    isRecording = true;
                    fullTranscript = '';
                    document.getElementById('voiceBtn').classList.add('recording');
                    document.getElementById('voiceBtn').textContent = '🔴 Recording... Tap to Stop';
                    document.getElementById('status').textContent = 'Listening...';
                    document.getElementById('transcript').innerHTML = '<span class="placeholder">Listening...</span>';
                    document.getElementById('submitBtn').disabled = true;

                    try {
                        recognition.start();
                    } catch (e) {
                        // Already started
                    }
                }

                function stopRecording() {
                    isRecording = false;
                    document.getElementById('voiceBtn').classList.remove('recording');
                    document.getElementById('voiceBtn').textContent = '🎤 Tap to Talk';
                    document.getElementById('status').textContent = fullTranscript ? 'Review and save below' : 'Tap the button and speak clearly';

                    if (recognition) {
                        recognition.stop();
                    }
                }
            </script>
        </body>
        </html>
    `);
});

//=============================================================================
// ROUTES: PHOTO CAPTURE (Direct camera access)
//=============================================================================

app.get('/photo', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Futility's - Photo Capture</title>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <style>${STYLES}</style>
            <style>
                .photo-preview {
                    width: 100%;
                    max-height: 300px;
                    object-fit: contain;
                    border-radius: 12px;
                    margin: 15px 0;
                    display: none;
                }
                .photo-preview.has-image { display: block; }
            </style>
        </head>
        <body>
            <nav>
                <a href="/">Home</a>
                <a href="/voice">Voice</a>
                <a href="/photo">Photo</a>
                <a href="/browse">Browse</a>
                <a href="/logout">Out</a>
            </nav>

            <h1>Photo Capture</h1>

            <div class="container">
                <form method="POST" action="/upload" enctype="multipart/form-data" id="photoForm">
                    <!-- Big camera button -->
                    <div class="file-input-wrapper">
                        <button type="button" class="btn-large action-btn photo" style="width:100%;">
                            <span class="icon">📷</span>
                            <span class="label" id="cameraLabel">Take Photo</span>
                        </button>
                        <input type="file"
                               name="file"
                               id="cameraInput"
                               accept="image/*"
                               capture="environment"
                               onchange="previewPhoto(this)" />
                    </div>

                    <!-- Photo preview -->
                    <img id="photoPreview" class="photo-preview" alt="Preview" />

                    <!-- Optional note -->
                    <textarea name="description"
                              placeholder="Add a note (optional): What is this? Equipment ID?"
                              rows="2"
                              style="margin-top: 15px;"></textarea>

                    <button type="submit" class="btn-large" id="submitBtn" disabled>
                        Save Photo
                    </button>
                </form>
            </div>

            <div class="container">
                <p class="meta" style="text-align:center;">
                    <strong>Tips:</strong><br>
                    • Nameplates: get close, make text readable<br>
                    • Problems: show the issue clearly<br>
                    • Gauges: capture the full reading
                </p>
            </div>

            <!-- Gallery option -->
            <div class="container">
                <p class="meta">Have an existing photo?</p>
                <div class="file-input-wrapper">
                    <button type="button" class="btn-secondary" style="width:100%;">
                        Choose from Gallery
                    </button>
                    <input type="file"
                           accept="image/*"
                           onchange="document.getElementById('cameraInput').files = this.files; previewPhoto(this);" />
                </div>
            </div>

            <script>
                function previewPhoto(input) {
                    const preview = document.getElementById('photoPreview');
                    const submitBtn = document.getElementById('submitBtn');
                    const label = document.getElementById('cameraLabel');

                    if (input.files && input.files[0]) {
                        const reader = new FileReader();

                        reader.onload = function(e) {
                            preview.src = e.target.result;
                            preview.classList.add('has-image');
                            submitBtn.disabled = false;
                            label.textContent = 'Retake Photo';
                        };

                        reader.readAsDataURL(input.files[0]);
                    }
                }
            </script>
        </body>
        </html>
    `);
});

//=============================================================================
// ROUTES: FILE UPLOAD
//=============================================================================

app.get('/upload', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Futility's - Upload Document</title>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <style>${STYLES}</style>
        </head>
        <body>
            <nav>
                <a href="/">Home</a>
                <a href="/voice">Voice</a>
                <a href="/photo">Photo</a>
                <a href="/browse">Browse</a>
                <a href="/logout">Out</a>
            </nav>

            <h1>Upload Document</h1>

            <div class="container">
                <form method="POST" action="/upload" enctype="multipart/form-data">
                    <div class="file-input-wrapper">
                        <button type="button" class="btn-large btn-secondary" style="width:100%;">
                            📄 Select File
                        </button>
                        <input type="file" name="file" accept=".pdf,.png,.jpg,.jpeg,.gif,.doc,.docx,.txt,.md" required />
                    </div>

                    <textarea name="description" rows="2" placeholder="What is this file? (optional)"></textarea>

                    <button type="submit" class="btn-large">Upload</button>
                </form>
            </div>

            <div class="container">
                <p class="meta" style="text-align:center;">
                    PDF, images, documents up to 50MB<br>
                    <a href="/photo">Take a photo instead?</a>
                </p>
            </div>
        </body>
        </html>
    `);
});

app.post('/upload', upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.redirect('/upload?error=nofile');
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const captureId = `FILE-${timestamp}`;
    const description = req.body.description || `Uploaded file: ${req.file.originalname}`;

    // Save to database
    db.prepare(`
        INSERT INTO captures (capture_id, content, input_type, file_path) VALUES (?, ?, ?, ?)
    `).run(captureId, description, 'file', req.file.path);

    logAudit('upload', { captureId, filename: req.file.originalname, size: req.file.size });

    res.redirect(`/success?id=${captureId}&type=file`);
});

//=============================================================================
// ROUTES: BROWSE
//=============================================================================

app.get('/browse', (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = 20;
    const offset = (page - 1) * limit;

    const total = db.prepare('SELECT COUNT(*) as count FROM captures').get().count;
    const captures = db.prepare(`
        SELECT * FROM captures ORDER BY created_at DESC LIMIT ? OFFSET ?
    `).all(limit, offset);

    const totalPages = Math.ceil(total / limit);

    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Futility's - Browse</title>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <style>${STYLES}</style>
        </head>
        <body>
            <nav>
                <a href="/">Home</a>
                <a href="/voice">Voice</a>
                <a href="/photo">Photo</a>
                <a href="/browse">Browse</a>
                <a href="/logout">Out</a>
            </nav>

            <h1>All Captures</h1>
            <p class="meta">${total} total · Page ${page}/${totalPages}</p>

            <div class="container">
                ${captures.length === 0 ? '<p class="meta">No captures yet!</p>' : ''}
                ${captures.map(c => \`
                    <div class="capture-item">
                        <div class="meta">
                            \${c.input_type} · \${new Date(c.created_at).toLocaleString()}
                            \${c.git_committed ? '<span class="success">✓</span>' : '<span class="warning">⏳</span>'}
                        </div>
                        <p>\${escapeHtml(c.content.substring(0, 150))}\${c.content.length > 150 ? '...' : ''}</p>
                        \${c.file_path ? '<p class="meta">📎 File</p>' : ''}
                    </div>
                \`).join('')}
            </div>

            <div style="display:flex; justify-content:center; gap:10px; margin: 20px 0;">
                ${page > 1 ? \`<a href="/browse?page=\${page-1}" class="btn btn-secondary">← Prev</a>\` : ''}
                ${page < totalPages ? \`<a href="/browse?page=\${page+1}" class="btn btn-secondary">Next →</a>\` : ''}
            </div>
        </body>
        </html>
    `);
});

//=============================================================================
// ROUTES: FEEDBACK
//=============================================================================

app.post('/feedback', (req, res) => {
    const { capture_id, rating, comment } = req.body;

    db.prepare(`
        INSERT INTO feedback (capture_id, rating, comment) VALUES (?, ?, ?)
    `).run(capture_id, rating, comment || null);

    logAudit('feedback', { capture_id, rating });

    res.json({ success: true });
});

//=============================================================================
// ROUTES: SUCCESS
//=============================================================================

app.get('/success', (req, res) => {
    const { id, type, git } = req.query;

    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Futility's - Saved!</title>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <style>${STYLES}</style>
        </head>
        <body>
            <nav>
                <a href="/">Home</a>
                <a href="/voice">Voice</a>
                <a href="/photo">Photo</a>
                <a href="/browse">Browse</a>
                <a href="/logout">Out</a>
            </nav>

            <div class="container" style="text-align: center;">
                <h1 class="success" style="font-size: 48px;">✓</h1>
                <h2>Saved!</h2>
                ${git === 'failed' ? '<p class="warning">Saved locally (Git push failed)</p>' : '<p class="success">Synced to Git</p>'}

                <div class="action-grid" style="margin-top: 30px;">
                    <a href="/voice" class="action-btn" style="text-decoration:none; color:white;">
                        <div class="icon">🎤</div>
                        <div class="label">Voice</div>
                    </a>
                    <a href="/photo" class="action-btn photo" style="text-decoration:none; color:white;">
                        <div class="icon">📷</div>
                        <div class="label">Photo</div>
                    </a>
                </div>

                <a href="/" class="btn btn-secondary" style="width:100%; margin-top: 15px;">Back to Home</a>
            </div>
        </body>
        </html>
    `);
});

//=============================================================================
// HELPERS
//=============================================================================

function escapeHtml(text) {
    return text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

//=============================================================================
// START SERVER
//=============================================================================

app.listen(CONFIG.PORT, () => {
    console.log(`
╔═══════════════════════════════════════════════════════════╗
║                    FUTILITY'S SSOT ENGINE                 ║
╠═══════════════════════════════════════════════════════════╣
║  Status:  Running                                         ║
║  Port:    ${CONFIG.PORT}                                           ║
║  Spec:    ${CONFIG.SPEC_DIR}
║  Data:    ${CONFIG.DATA_DIR}
╚═══════════════════════════════════════════════════════════╝
    `);
});
SERVEREOF

    print_success "Application created"

    SETUP_PHASE=9
    save_config
    print_success "Phase 9 complete!"
}

#===============================================================================
# PHASE 10: CONFIGURE AND START
#===============================================================================

phase10_start_app() {
    print_header "PHASE 10: CONFIGURE AND START"

    cd "$APP_DIR"

    # Create environment file
    print_step "Creating environment configuration..."
    cat > .env << EOF
PORT=3000
PIN=${PIN}
SPEC_DIR=${SPEC_DIR}
DATA_DIR=${DATA_DIR}
ANTHROPIC_KEY=${ANTHROPIC_KEY}
EOF
    chmod 600 .env

    # Create PM2 ecosystem file
    print_step "Creating PM2 configuration..."
    cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'futilitys',
    script: 'server.js',
    env: {
      PORT: 3000,
      PIN: '${PIN}',
      SPEC_DIR: '${SPEC_DIR}',
      DATA_DIR: '${DATA_DIR}',
      ANTHROPIC_KEY: '${ANTHROPIC_KEY}'
    },
    watch: false,
    max_memory_restart: '500M',
    error_file: '${DATA_DIR}/logs/error.log',
    out_file: '${DATA_DIR}/logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss'
  }]
};
EOF

    # Create logs directory
    mkdir -p "${DATA_DIR}/logs"

    # Stop existing if running
    pm2 delete futilitys 2>/dev/null || true

    # Start with PM2
    print_step "Starting application with PM2..."
    pm2 start ecosystem.config.js
    pm2 save

    # Setup PM2 startup
    print_step "Configuring PM2 to start on boot..."
    pm2 startup systemd -u "$USER" --hp "$HOME" | tail -1 | bash || true

    print_success "Application started"

    SETUP_PHASE=10
    save_config
    print_success "Phase 10 complete!"
}

#===============================================================================
# PHASE 11: CONFIGURE CADDY
#===============================================================================

phase11_configure_caddy() {
    print_header "PHASE 11: CONFIGURE WEB SERVER"

    print_step "Configuring Caddy for $DOMAIN..."

    # Backup existing config
    sudo cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.backup 2>/dev/null || true

    # Check if using IP or domain
    if [[ "$DOMAIN" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # IP address - no HTTPS
        sudo tee /etc/caddy/Caddyfile > /dev/null << EOF
:80 {
    reverse_proxy localhost:3000
}
EOF
        print_warning "Using IP address - HTTPS not available"
        print_info "Access your site at: http://$DOMAIN"
    else
        # Domain - with HTTPS
        sudo tee /etc/caddy/Caddyfile > /dev/null << EOF
${DOMAIN} {
    reverse_proxy localhost:3000
}

www.${DOMAIN} {
    redir https://${DOMAIN}{uri}
}
EOF
        print_info "Access your site at: https://$DOMAIN"
    fi

    print_step "Restarting Caddy..."
    sudo systemctl restart caddy

    # Wait a moment for Caddy to start
    sleep 3

    if sudo systemctl is-active --quiet caddy; then
        print_success "Caddy is running"
    else
        print_error "Caddy failed to start. Check: sudo journalctl -u caddy"
    fi

    SETUP_PHASE=11
    save_config
    print_success "Phase 11 complete!"
}

#===============================================================================
# PHASE 12: FINAL CHECKS
#===============================================================================

phase12_final_checks() {
    print_header "PHASE 12: FINAL CHECKS"

    echo ""
    print_step "Checking services..."

    # Check PM2
    if pm2 list | grep -q "futilitys"; then
        print_success "Futility's app is running"
    else
        print_error "Futility's app is NOT running"
    fi

    # Check Caddy
    if sudo systemctl is-active --quiet caddy; then
        print_success "Caddy web server is running"
    else
        print_error "Caddy is NOT running"
    fi

    # Check if port 3000 is listening
    if netstat -tuln 2>/dev/null | grep -q ":3000 " || ss -tuln | grep -q ":3000 "; then
        print_success "Application is listening on port 3000"
    else
        print_warning "Port 3000 not detected (app may still be starting)"
    fi

    # Test local connection
    print_step "Testing local connection..."
    if curl -s http://localhost:3000/login | grep -q "Futility"; then
        print_success "Application responds correctly"
    else
        print_warning "Could not verify application response"
    fi

    SETUP_PHASE=12
    save_config

    echo ""
    echo ""
    print_header "🎉 INSTALLATION COMPLETE!"
    echo ""

    if [[ "$DOMAIN" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "  ${BOLD}Your site is ready at:${NC} ${GREEN}http://${DOMAIN}${NC}"
    else
        echo -e "  ${BOLD}Your site is ready at:${NC} ${GREEN}https://${DOMAIN}${NC}"
    fi

    echo ""
    echo -e "  ${BOLD}PIN:${NC} ${YELLOW}${PIN}${NC}"
    echo ""
    echo -e "  ${CYAN}Useful commands:${NC}"
    echo "    pm2 logs futilitys     - View application logs"
    echo "    pm2 restart futilitys  - Restart the application"
    echo "    pm2 status             - Check status"
    echo ""
    echo -e "  ${CYAN}Configuration saved to:${NC} $CONFIG_FILE"
    echo ""

    if [[ ! "$DOMAIN" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_warning "If using a new domain, make sure DNS is configured:"
        echo "    Add an A record pointing to: $(curl -s ifconfig.me)"
        echo ""
    fi

    print_success "You're all set! Go capture some knowledge."
}

#===============================================================================
# MAIN WIZARD LOGIC
#===============================================================================

main() {
    clear
    echo ""
    echo -e "${CYAN}"
    echo '  ╔═══════════════════════════════════════════════════════════╗'
    echo '  ║                                                           ║'
    echo '  ║     ███████╗██╗   ██╗████████╗██╗██╗     ██╗████████╗    ║'
    echo '  ║     ██╔════╝██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝    ║'
    echo '  ║     █████╗  ██║   ██║   ██║   ██║██║     ██║   ██║       ║'
    echo '  ║     ██╔══╝  ██║   ██║   ██║   ██║██║     ██║   ██║       ║'
    echo '  ║     ██║     ╚██████╔╝   ██║   ██║███████╗██║   ██║       ║'
    echo '  ║     ╚═╝      ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝       ║'
    echo '  ║                                                           ║'
    echo '  ║            SSOT ENGINE - INSTALLATION WIZARD              ║'
    echo '  ║                                                           ║'
    echo '  ╚═══════════════════════════════════════════════════════════╝'
    echo -e "${NC}"
    echo ""

    print_step "Running prerequisite checks..."
    check_ubuntu
    check_internet
    IS_ROOT=$(check_root && echo "yes" || echo "no")

    echo ""
    print_info "Current setup phase: ${SETUP_PHASE:-0}"
    echo ""

    # Determine where to start based on saved state
    CURRENT_PHASE=${SETUP_PHASE:-0}

    if [ "$CURRENT_PHASE" -lt 1 ] && [ "$IS_ROOT" = "yes" ]; then
        phase1_system_setup
        CURRENT_PHASE=1
    fi

    if [ "$CURRENT_PHASE" -lt 2 ]; then
        phase2_create_user
        CURRENT_PHASE=2
    fi

    if [ "$CURRENT_PHASE" -lt 3 ]; then
        phase3_install_node
        CURRENT_PHASE=3
    fi

    if [ "$CURRENT_PHASE" -lt 4 ]; then
        phase4_install_caddy
        CURRENT_PHASE=4
    fi

    if [ "$CURRENT_PHASE" -lt 5 ]; then
        phase5_install_gh
        CURRENT_PHASE=5
    fi

    if [ "$CURRENT_PHASE" -lt 6 ]; then
        phase6_ssh_key
        CURRENT_PHASE=6
    fi

    if [ "$CURRENT_PHASE" -lt 7 ]; then
        phase7_collect_config
        CURRENT_PHASE=7
    fi

    if [ "$CURRENT_PHASE" -lt 8 ]; then
        phase8_clone_repo
        CURRENT_PHASE=8
    fi

    if [ "$CURRENT_PHASE" -lt 9 ]; then
        phase9_create_app
        CURRENT_PHASE=9
    fi

    if [ "$CURRENT_PHASE" -lt 10 ]; then
        phase10_start_app
        CURRENT_PHASE=10
    fi

    if [ "$CURRENT_PHASE" -lt 11 ]; then
        phase11_configure_caddy
        CURRENT_PHASE=11
    fi

    if [ "$CURRENT_PHASE" -lt 12 ]; then
        phase12_final_checks
        CURRENT_PHASE=12
    fi
}

# Run main function
main "$@"
