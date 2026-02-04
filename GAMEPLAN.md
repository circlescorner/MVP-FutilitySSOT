# Gameplan — Step-by-Step Setup Guide

**For absolute beginners.** This guide assumes no prior server experience.

Each phase ends with a checkpoint. Don't proceed until you've completed it.

> **Faster option:** Run `bash install.sh` on your server to automate most of these steps.

---

## Phase 0: Create Your Accounts

Before touching any code, create accounts on these services:

| Service | URL | Purpose |
|---------|-----|---------|
| GitHub | github.com | Code storage |
| DigitalOcean | digitalocean.com | Server hosting |
| Cloudflare | cloudflare.com | Domain/DNS (optional) |
| Anthropic | console.anthropic.com | AI features (optional) |

### Checkpoint
- [ ] Can log into GitHub
- [ ] Can log into DigitalOcean
- [ ] Have Anthropic API key saved (if using AI features)

---

## Phase 1: Create Your Server

A "droplet" is DigitalOcean's name for a virtual server.

### Step 1.1: Create an SSH Key

**What is SSH?** A secure way to connect to remote computers. An SSH key is more secure than a password.

**Windows (PowerShell):**
```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Mac/Linux (Terminal):**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Press Enter to accept defaults. View your public key:
```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the entire output (starts with `ssh-ed25519`).

### Step 1.2: Add SSH Key to DigitalOcean

1. DigitalOcean → Settings → Security → Add SSH Key
2. Paste your public key
3. Name it "My Laptop"

### Step 1.3: Create the Droplet

1. DigitalOcean → Create → Droplets
2. **Region:** Pick closest to you
3. **Image:** Ubuntu 22.04 (LTS) x64
4. **Size:** Basic → Regular → $12/mo (2GB RAM)
5. **Authentication:** Select your SSH key
6. **Hostname:** `futilitys-server`
7. Click Create Droplet
8. **Copy the IP address** (e.g., `167.99.123.45`)

### Step 1.4: Connect to Your Server

```bash
ssh root@YOUR_IP_ADDRESS
```

Type `yes` if asked about fingerprint. You're now on your server.

### Step 1.5: Run the Install Script

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/install.sh -o install.sh
bash install.sh
```

The script handles everything from here. Follow the prompts.

### Checkpoint
- [ ] Droplet shows green dot in DigitalOcean
- [ ] Can SSH into server
- [ ] Install script is running

---

## Phase 2: Manual Setup (If Not Using Script)

*Skip this section if you ran `install.sh`.*

### Update System
```bash
apt update && apt upgrade -y
```

### Create Non-Root User
```bash
adduser gondor
usermod -aG sudo gondor
mkdir -p /home/gondor/.ssh
cp ~/.ssh/authorized_keys /home/gondor/.ssh/
chown -R gondor:gondor /home/gondor/.ssh
```

### Test New User (new terminal)
```bash
ssh gondor@YOUR_IP_ADDRESS
```

### Checkpoint
- [ ] Can SSH as new user (not root)

---

## Phase 3: Domain Setup (Optional)

*Skip if using IP address only.*

### Point Domain to Server

In Cloudflare (or your DNS provider):

| Type | Name | Value |
|------|------|-------|
| A | @ | YOUR_DROPLET_IP |
| A | www | YOUR_DROPLET_IP |

Wait 5-30 minutes for DNS propagation.

### Checkpoint
- [ ] `https://yourdomain.com` loads without errors
- [ ] Padlock icon shows (HTTPS working)

---

## Phase 4: Verify Installation

After `install.sh` completes:

```bash
pm2 status          # App should show "online"
sudo systemctl status caddy   # Should show "active"
```

Visit your site:
- With domain: `https://yourdomain.com`
- With IP: `http://YOUR_IP_ADDRESS`

Log in with the PIN you set during installation.

### Checkpoint
- [ ] Site loads
- [ ] Can log in with PIN
- [ ] Can submit a capture
- [ ] Capture appears in GitHub repo

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't SSH | Check IP address; verify SSH key is correct |
| Site not loading | `pm2 status` and `sudo systemctl status caddy` |
| Git push failing | Verify deploy key has write access on GitHub |
| Domain not working | Check DNS at dnschecker.org; wait for propagation |

## Useful Commands

```bash
# View app logs
pm2 logs futilitys

# Restart app
pm2 restart futilitys

# Restart web server
sudo systemctl restart caddy

# Check disk space
df -h

# Check memory
free -h
```

---

## What's Next

With the basic system running, future phases include:

- AI-powered claim extraction
- Asset database and resolution
- Verification workflow
- SSOT Explorer interface
- Document and photo uploads
- Mobile-friendly export

See [docs/ROADMAP.md](docs/ROADMAP.md) for the complete plan.

---

**Need the full manual setup?** The complete step-by-step commands are preserved in the [install.sh](install.sh) script comments.
