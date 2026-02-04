# Setup Requirements

**Read this before running the installation script.**

---

## Prerequisites

Create these accounts before you begin:

| Service | URL | Required? | Purpose |
|---------|-----|-----------|---------|
| GitHub | github.com | Yes | Code repository and version control |
| DigitalOcean | digitalocean.com | Yes | Server hosting ($12/month) |
| Cloudflare | cloudflare.com | Optional | Domain management and DNS |
| Anthropic | console.anthropic.com | Optional | AI features (Claude API) |

---

## What You'll Create During Setup

The installation wizard will prompt you to create these credentials:

| Step | Credential | Description | Example |
|------|------------|-------------|---------|
| Before script | SSH key passphrase | Protects your SSH key | *(can leave blank)* |
| Phase 2 | Server username | Your login on the server | `gondor` |
| Phase 2 | Server password | For sudo commands | *(you choose)* |
| Phase 7 | Web interface PIN | Access code for the app | `5821` |

**Write these down before you start.**

---

## Authorization by Phase

### Before Running the Script

| Task | Authorization Needed |
|------|---------------------|
| Create DigitalOcean droplet | DigitalOcean account + payment method |
| Create SSH key | None (runs on your computer) |
| SSH into server | Your SSH key |

### During the Script

| Phase | What Happens | Authorization |
|-------|--------------|---------------|
| 1 | System updates | None (automatic) |
| 2 | Create server user | **You create:** username + password |
| 3 | Install Node.js | None (automatic) |
| 4 | Install Caddy | None (automatic) |
| 5 | GitHub CLI setup | **GitHub login** via browser |
| 6 | Generate deploy key | **Manual:** Add key to GitHub repo |
| 7 | Configuration | **You enter:** domain, repo, PIN |
| 8-12 | App deployment | None (automatic) |

### Manual Steps (Script Will Pause)

1. **Phase 2** — After creating the server user, you must:
   - Open a new terminal
   - SSH in as the new user: `ssh username@YOUR_IP`
   - Run the script again

2. **Phase 5** — GitHub CLI authentication:
   - Browser window opens
   - Log into GitHub
   - Authorize the CLI

3. **Phase 6** — Deploy key setup:
   - Copy the displayed SSH public key
   - Go to GitHub → Your Repo → Settings → Deploy keys
   - Add key with "Allow write access" checked

4. **Phase 11** — If using a domain:
   - Add DNS A record pointing to your server IP
   - Wait 5-30 minutes for propagation

---

## Checklist

**Have ready before starting:**

- [ ] GitHub account (logged in via browser)
- [ ] DigitalOcean account with payment method
- [ ] Droplet created (Ubuntu 22.04, $12/month tier)
- [ ] Droplet IP address copied
- [ ] Terminal or PowerShell open
- [ ] Decided on: server username, server password, web PIN
- [ ] *(Optional)* Anthropic API key
- [ ] *(Optional)* Domain name

---

## Time Estimate

| Task | Duration |
|------|----------|
| Account creation | 10-15 min (one time) |
| Droplet creation | 2-3 min |
| Running install.sh | 15-20 min |
| DNS propagation | 5-30 min (if using domain) |
| **Total** | **~45 minutes** |

---

## Cost Summary

| Item | Cost |
|------|------|
| DigitalOcean droplet | $12/month |
| Domain name | $3-15/year *(optional)* |
| Anthropic API | ~$5-15/month *(usage-based, optional)* |
| **Minimum** | **$12/month** |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Permission denied" on SSH | Check SSH key path: `ssh -i ~/.ssh/id_ed25519 user@IP` |
| "Repository not found" | Verify deploy key added to GitHub with write access |
| Site not loading | Run `pm2 status` and `sudo systemctl status caddy` |
| Domain not working | Check DNS at dnschecker.org; wait for propagation |

---

**Next step:** [GAMEPLAN.md](GAMEPLAN.md) for detailed walkthrough, or just run `bash install.sh`
