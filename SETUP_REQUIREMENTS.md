===============================================================================
FUTILITY'S — SETUP REQUIREMENTS & TIPS
===============================================================================

Read this BEFORE running install.sh

===============================================================================
ACCOUNTS YOU NEED (CREATE THESE FIRST)
===============================================================================

Create these accounts before you start. All have free tiers.

  □ GitHub          https://github.com
                    → You'll authorize the server to push to your repo

  □ DigitalOcean    https://www.digitalocean.com
                    → Requires credit card (not charged until you create droplet)
                    → Often has $200 free credit for new accounts

  □ Anthropic       https://console.anthropic.com  (optional, for AI features)
                    → Create an API key and save it somewhere

  □ Domain          https://namecheap.com or https://cloudflare.com (optional)
                    → Can use IP address instead for testing

===============================================================================
PASSWORDS/LOGINS YOU WILL CREATE
===============================================================================

During setup, YOU will choose these (write them down):

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ STEP          │ WHAT YOU CREATE        │ EXAMPLE                       │
  ├─────────────────────────────────────────────────────────────────────────┤
  │ DigitalOcean  │ SSH key passphrase     │ (can be blank for no password)│
  │ Phase 2       │ Server username        │ gondor                        │
  │ Phase 2       │ Server user password   │ (you choose, for sudo)        │
  │ Phase 7       │ Web interface PIN      │ 5821 (4-8 digits you remember)│
  └─────────────────────────────────────────────────────────────────────────┘

===============================================================================
STEP-BY-STEP AUTHORIZATION GUIDE
===============================================================================

BEFORE THE SCRIPT (do these manually)
─────────────────────────────────────

1. CREATE DIGITALOCEAN DROPLET
   Where: DigitalOcean dashboard → Create → Droplets
   Auth needed: Your DigitalOcean account
   You choose:
     • Region (pick closest to you)
     • Size: $12/mo (2GB RAM)
     • SSH key (see below)

2. CREATE SSH KEY (on your laptop)
   Windows PowerShell / Mac Terminal:
     ssh-keygen -t ed25519 -C "your_email@example.com"

   You choose: Passphrase (or press Enter for none)
   Copy the PUBLIC key to DigitalOcean (Settings → Security → Add SSH Key)

3. GET YOUR DROPLET IP
   After droplet creates, copy the IP address (e.g., 167.99.123.45)


DURING THE SCRIPT
─────────────────

Phase 1: SYSTEM SETUP
  Auth: None (runs automatically)
  Creates: Nothing

Phase 2: CREATE USER
  ★ YOU CREATE: Username (e.g., "gondor")
  ★ YOU CREATE: Password for that user (for sudo commands)
  Auth: None

  ⚠️  SCRIPT WILL EXIT HERE - you must:
      1. Open NEW terminal
      2. SSH as new user: ssh gondor@YOUR_IP
      3. Run script again: bash install.sh

Phase 3: INSTALL NODE.JS
  Auth: None (runs automatically)
  Creates: Nothing

Phase 4: INSTALL CADDY
  Auth: None (runs automatically)
  Creates: Nothing

Phase 5: GITHUB CLI
  ★ AUTH REQUIRED: GitHub account
  How: Script opens browser, you log into GitHub and authorize
  Creates: Nothing new (uses existing GitHub account)

Phase 6: DEPLOY KEY
  Auth: None (generates automatically)
  Creates: SSH key pair for server→GitHub

  ⚠️  MANUAL STEP: Copy the displayed key to GitHub
      1. Go to your repo on GitHub
      2. Settings → Deploy keys → Add deploy key
      3. Paste key, check "Allow write access"
      4. Click Add key

Phase 7: CONFIGURATION
  ★ YOU ENTER: Domain name (or press Enter to use IP)
  ★ YOU ENTER: GitHub repo (e.g., "yourname/MVP-FutilitySSOT")
  ★ YOU CREATE: PIN for web interface (4-8 digits)
  ★ YOU ENTER: Anthropic API key (optional, press Enter to skip)

Phase 8: CLONE REPO
  Auth: Uses deploy key from Phase 6
  Creates: Nothing

Phase 9: CREATE APP
  Auth: None (runs automatically)
  Creates: Nothing

Phase 10: START APP
  Auth: None (runs automatically)
  Creates: Nothing

Phase 11: CONFIGURE WEB SERVER
  Auth: None (runs automatically)
  Creates: Nothing

  ⚠️  IF USING DOMAIN: Make sure DNS points to your droplet IP
      Cloudflare/Namecheap → DNS → A record → your droplet IP

Phase 12: DONE!
  Your site is live at https://yourdomain.com (or http://YOUR_IP)
  Log in with the PIN you created in Phase 7

===============================================================================
QUICK REFERENCE: WHAT TO HAVE READY
===============================================================================

  □ GitHub account logged in (in a browser)
  □ DigitalOcean account with droplet created
  □ Droplet IP address copied
  □ Terminal/PowerShell open
  □ This list of things you'll create:
      • Server username: _______________
      • Server password: _______________
      • Web PIN: _______________
  □ (Optional) Anthropic API key copied
  □ (Optional) Domain name purchased

===============================================================================
COMMON ISSUES
===============================================================================

"Permission denied" when SSH'ing
  → Make sure you're using the right SSH key
  → ssh -i ~/.ssh/id_ed25519 user@IP

"Repository not found" during clone
  → Deploy key not added to GitHub, or wrong repo name
  → Check: Settings → Deploy keys on your GitHub repo

Site not loading after setup
  → Check if app is running: pm2 status
  → Check Caddy: sudo systemctl status caddy
  → Check firewall: sudo ufw status

Domain not working
  → DNS takes 5-30 minutes to propagate
  → Check at: https://dnschecker.org
  → Make sure A record points to your droplet IP

===============================================================================
TIME ESTIMATE
===============================================================================

  Creating accounts:     10-15 min (one time)
  Creating droplet:      5 min
  Running install.sh:    15-20 min
  DNS propagation:       5-30 min (if using domain)
                         ─────────
  Total first time:      ~45 min

===============================================================================
COST SUMMARY
===============================================================================

  DigitalOcean droplet:  $12/month
  Domain (optional):     $3-15/year
  Anthropic API:         ~$5-15/month (usage based)
                         ────────────
  Minimum to start:      $12/month

===============================================================================
