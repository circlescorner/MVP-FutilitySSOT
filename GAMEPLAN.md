===============================================================================
FUTILITY'S — GAMEPLAN (ABSOLUTE BEGINNER GUIDE)
===============================================================================

This guide assumes you have never touched a server, don't know what SSH is,
and need every step explained. Follow it in order. Don't skip ahead.

Each phase ends with a clear "YOU'RE DONE WHEN..." checkpoint.

===============================================================================
PHASE 0: GET YOUR ACCOUNTS SET UP
===============================================================================

Before you touch any code, you need accounts on these services.
All of these have free tiers or trials.

STEP 0.1: Create a GitHub account (if you don't have one)
─────────────────────────────────────────────────────────
1. Go to https://github.com
2. Click "Sign up"
3. Follow the steps (email, password, username)
4. Verify your email

WHY: GitHub stores your code and handles version control.


STEP 0.2: Create a DigitalOcean account
───────────────────────────────────────
1. Go to https://www.digitalocean.com
2. Click "Sign up"
3. You can sign up with your GitHub account (easier)
4. Add a payment method (credit card or PayPal)
   - You won't be charged until you create resources
   - They often have $200 free credit for new accounts

WHY: DigitalOcean is where your server will live.


STEP 0.3: Create a Cloudflare account (for domain/DNS)
──────────────────────────────────────────────────────
1. Go to https://www.cloudflare.com
2. Click "Sign up"
3. Free tier is fine

WHY: Cloudflare manages your domain and gives you free HTTPS.


STEP 0.4: Buy a domain name (optional but recommended)
──────────────────────────────────────────────────────
1. Go to https://www.namecheap.com or https://www.cloudflare.com/products/registrar/
2. Search for a domain you like (e.g., "futilitys.xyz" or "yourfactoryname.com")
3. Buy it (~$10-15/year for .com, ~$3-5/year for .xyz)

WHY: A domain gives you a real web address instead of an IP number.

ALTERNATIVE: You can skip this and use the IP address directly for testing.


STEP 0.5: Create an Anthropic account (for Claude API)
──────────────────────────────────────────────────────
1. Go to https://console.anthropic.com
2. Sign up
3. Add payment method
4. Go to "API Keys" and create a new key
5. SAVE THIS KEY SOMEWHERE SAFE (you won't see it again)

WHY: This is how your system will talk to Claude for AI features.

───────────────────────────────────────────────────────────────────────────────
★ YOU'RE DONE WITH PHASE 0 WHEN:
  [ ] You can log into GitHub
  [ ] You can log into DigitalOcean
  [ ] You can log into Cloudflare
  [ ] You have a domain (or decided to skip for now)
  [ ] You have an Anthropic API key saved somewhere safe
───────────────────────────────────────────────────────────────────────────────


===============================================================================
PHASE 1: CREATE YOUR SERVER (DROPLET)
===============================================================================

A "droplet" is DigitalOcean's name for a virtual server.
Think of it as renting a computer that lives in a data center.

STEP 1.1: Create an SSH key (so you can log into your server securely)
──────────────────────────────────────────────────────────────────────

WHAT IS SSH?
  SSH is a secure way to connect to a remote computer and type commands.
  An SSH key is like a special password file that's more secure than typing.

ON WINDOWS:
1. Open PowerShell (search for "PowerShell" in Start menu)
2. Type: ssh-keygen -t ed25519 -C "your_email@example.com"
3. Press Enter to accept the default file location
4. Press Enter twice (no passphrase, or add one if you want extra security)
5. Your key is now in: C:\Users\YourName\.ssh\id_ed25519.pub

ON MAC:
1. Open Terminal (search for "Terminal" in Spotlight)
2. Type: ssh-keygen -t ed25519 -C "your_email@example.com"
3. Press Enter to accept defaults
4. Your key is now in: ~/.ssh/id_ed25519.pub

TO VIEW YOUR PUBLIC KEY:
  Windows: type C:\Users\YourName\.ssh\id_ed25519.pub
  Mac/Linux: cat ~/.ssh/id_ed25519.pub

  It will look like: ssh-ed25519 AAAAC3Nza... your_email@example.com

COPY THIS ENTIRE LINE. You'll need it in the next step.


STEP 1.2: Add your SSH key to DigitalOcean
──────────────────────────────────────────
1. Log into DigitalOcean
2. Click "Settings" in the left sidebar
3. Click "Security"
4. Click "Add SSH Key"
5. Paste your public key (the ssh-ed25519 AAAAC3... line)
6. Give it a name like "My Laptop"
7. Click "Add SSH Key"


STEP 1.3: Create the droplet
────────────────────────────
1. In DigitalOcean, click "Create" → "Droplets"
2. Choose region: Pick one close to you (e.g., New York, San Francisco)
3. Choose image: Ubuntu 22.04 (LTS) x64
4. Choose size:
   - Click "Basic"
   - Click "Regular" (not Premium)
   - Select "$12/mo" (2 GB RAM, 1 CPU, 50 GB disk)
5. Authentication: Select your SSH key (the one you just added)
6. Hostname: Give it a name like "futilitys-server"
7. Click "Create Droplet"
8. Wait ~60 seconds for it to create
9. COPY THE IP ADDRESS (it looks like: 167.99.123.45)


STEP 1.4: Connect to your server for the first time
───────────────────────────────────────────────────

ON WINDOWS:
1. Open PowerShell
2. Type: ssh root@YOUR_IP_ADDRESS
   (replace YOUR_IP_ADDRESS with the IP you copied, e.g., ssh root@167.99.123.45)
3. If asked "Are you sure you want to continue connecting?" type: yes
4. You should now see a command prompt that looks like: root@futilitys-server:~#

ON MAC:
1. Open Terminal
2. Type: ssh root@YOUR_IP_ADDRESS
3. Type "yes" if asked about fingerprint
4. You're in!

WHAT JUST HAPPENED?
  You're now typing commands on a computer in a data center somewhere.
  Everything you type happens on that remote computer, not your laptop.

TO DISCONNECT:
  Type: exit
  (or just close the window)


STEP 1.5: Basic server setup
────────────────────────────
While connected to your server, run these commands one at a time:

1. Update the system:
   apt update && apt upgrade -y

   (This downloads and installs security updates. Takes 1-2 minutes.)

2. Set the timezone:
   timedatectl set-timezone America/New_York

   (Change to your timezone. Use: timedatectl list-timezones to see options)

3. Create a non-root user (more secure):
   adduser gondor

   (It will ask for a password. Pick something you'll remember.)
   (Press Enter to skip the Full Name, Room Number, etc. questions)

4. Give that user admin powers:
   usermod -aG sudo gondor

5. Allow that user to use your SSH key:
   mkdir -p /home/gondor/.ssh
   cp ~/.ssh/authorized_keys /home/gondor/.ssh/
   chown -R gondor:gondor /home/gondor/.ssh

6. Test the new user (open a NEW terminal window):
   ssh gondor@YOUR_IP_ADDRESS

   If it works, you're good!

7. (Optional but recommended) Disable root login:
   Back in your root session:
   nano /etc/ssh/sshd_config

   Find the line: PermitRootLogin yes
   Change it to: PermitRootLogin no

   Press Ctrl+O to save, Enter to confirm, Ctrl+X to exit

   Then restart SSH:
   systemctl restart sshd

───────────────────────────────────────────────────────────────────────────────
★ YOU'RE DONE WITH PHASE 1 WHEN:
  [ ] You have a droplet running (green dot in DigitalOcean)
  [ ] You can SSH into it: ssh gondor@YOUR_IP_ADDRESS
  [ ] You see a prompt like: gondor@futilitys-server:~$
───────────────────────────────────────────────────────────────────────────────


===============================================================================
PHASE 2: SET UP YOUR DOMAIN AND HTTPS
===============================================================================

STEP 2.1: Point your domain to your server
──────────────────────────────────────────

If you bought a domain through Cloudflare:
1. Log into Cloudflare
2. Click on your domain
3. Click "DNS"
4. Add a record:
   - Type: A
   - Name: @ (this means the root domain)
   - IPv4 address: YOUR_DROPLET_IP
   - Proxy status: Proxied (orange cloud)
5. Add another record:
   - Type: A
   - Name: www
   - IPv4 address: YOUR_DROPLET_IP
   - Proxy status: Proxied

If you bought elsewhere (Namecheap, etc.):
1. In your registrar, change nameservers to Cloudflare's:
   - ns1.cloudflare.com
   - ns2.cloudflare.com
2. Then add the DNS records in Cloudflare as above

WAIT 5-30 MINUTES for DNS to propagate.


STEP 2.2: Test your domain
──────────────────────────
Open a browser and go to: http://yourdomain.com

You should see "Welcome to nginx!" or a connection refused error.
Either means DNS is working! (We haven't set up a web server yet.)


STEP 2.3: Install a web server (Caddy)
──────────────────────────────────────
Caddy is a web server that automatically handles HTTPS for you.

SSH into your server:
ssh gondor@YOUR_IP_ADDRESS

Run these commands:

1. Install Caddy:
   sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
   sudo apt update
   sudo apt install caddy

2. Create a test webpage:
   sudo mkdir -p /var/www/futilitys
   echo "<h1>Futility's is alive!</h1>" | sudo tee /var/www/futilitys/index.html

3. Configure Caddy:
   sudo nano /etc/caddy/Caddyfile

   Delete everything in the file and replace with:

   yourdomain.com {
       root * /var/www/futilitys
       file_server
   }

   (Replace yourdomain.com with your actual domain)

   Press Ctrl+O, Enter, Ctrl+X to save and exit.

4. Restart Caddy:
   sudo systemctl restart caddy

5. Test it:
   Open your browser and go to: https://yourdomain.com
   You should see "Futility's is alive!" with a padlock (HTTPS working!)

───────────────────────────────────────────────────────────────────────────────
★ YOU'RE DONE WITH PHASE 2 WHEN:
  [ ] https://yourdomain.com shows your test page
  [ ] There's a padlock icon (HTTPS is working)
  [ ] No certificate warnings
───────────────────────────────────────────────────────────────────────────────


===============================================================================
PHASE 3: INSTALL THE TOOLS YOU'LL NEED
===============================================================================

SSH into your server and run these commands:

STEP 3.1: Install Node.js (for running JavaScript on the server)
────────────────────────────────────────────────────────────────
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

Test it:
node --version
(Should show v20.something)


STEP 3.2: Install Git (for version control)
───────────────────────────────────────────
sudo apt install -y git

Configure it:
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"


STEP 3.3: Install GitHub CLI (for creating PRs from the server)
───────────────────────────────────────────────────────────────
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

Authenticate with GitHub:
gh auth login
- Select: GitHub.com
- Select: HTTPS
- Select: Yes (authenticate Git)
- Select: Login with a web browser
- Copy the code it shows you
- Press Enter to open browser
- Paste the code and authorize


STEP 3.4: Install SQLite (for the database)
───────────────────────────────────────────
sudo apt install -y sqlite3


STEP 3.5: Install PM2 (keeps your app running)
──────────────────────────────────────────────
sudo npm install -g pm2

PM2 will restart your app if it crashes and keep it running when you log out.


STEP 3.6: Create project directories
────────────────────────────────────
sudo mkdir -p /var/lib/futilitys/artifacts
sudo mkdir -p /var/lib/futilitys/data
sudo chown -R gondor:gondor /var/lib/futilitys

mkdir -p ~/futilitys
cd ~/futilitys

───────────────────────────────────────────────────────────────────────────────
★ YOU'RE DONE WITH PHASE 3 WHEN:
  [ ] node --version shows v20.x
  [ ] git --version shows something
  [ ] gh --version shows something
  [ ] sqlite3 --version shows something
  [ ] pm2 --version shows something
  [ ] /var/lib/futilitys/ directory exists
───────────────────────────────────────────────────────────────────────────────


===============================================================================
PHASE 4: CLONE YOUR REPOSITORY
===============================================================================

STEP 4.1: Generate a deploy key for this server
───────────────────────────────────────────────
On your server:
ssh-keygen -t ed25519 -C "futilitys-server-deploy"

Press Enter for default location, Enter twice for no passphrase.

View the public key:
cat ~/.ssh/id_ed25519.pub

Copy the entire line.


STEP 4.2: Add deploy key to GitHub
──────────────────────────────────
1. Go to your GitHub repository
2. Click "Settings"
3. Click "Deploy keys" in the left sidebar
4. Click "Add deploy key"
5. Title: "Futilitys Server"
6. Key: Paste the key you copied
7. Check "Allow write access"
8. Click "Add key"


STEP 4.3: Clone the repository
──────────────────────────────
On your server:
cd ~
git clone git@github.com:YOUR_USERNAME/MVP-FutilitySSOT.git futilitys-spec

(Replace YOUR_USERNAME with your GitHub username)

If asked about fingerprint, type "yes".


STEP 4.4: Verify it worked
──────────────────────────
cd ~/futilitys-spec
ls -la

You should see your files: Readme.md, docs/, deprecated/, etc.

───────────────────────────────────────────────────────────────────────────────
★ YOU'RE DONE WITH PHASE 4 WHEN:
  [ ] ~/futilitys-spec/ contains your repository files
  [ ] git pull works without errors
  [ ] git push works without errors (test with a small change if you want)
───────────────────────────────────────────────────────────────────────────────


===============================================================================
PHASE 5: BUILD A MINIMAL WEB INTERFACE
===============================================================================

This is where actual coding begins. You have two options:

OPTION A: Have Claude Code build it for you (recommended)
OPTION B: Build it yourself step by step

For now, let's create the absolute minimum: a webpage where you can
paste text and have it create a file in your repository.

STEP 5.1: Initialize a Node.js project
──────────────────────────────────────
cd ~/futilitys
npm init -y


STEP 5.2: Install dependencies
──────────────────────────────
npm install express body-parser


STEP 5.3: Create a minimal server
─────────────────────────────────
nano server.js

Paste this code:

const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const app = express();
const PORT = 3000;

// Where your spec repo is cloned
const REPO_PATH = '/home/gondor/futilitys-spec';

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Simple HTML form
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head><title>Futility's - Intake</title></head>
    <body style="font-family: monospace; max-width: 800px; margin: 50px auto; padding: 20px;">
      <h1>Futility's - Intake</h1>
      <form method="POST" action="/submit">
        <p><strong>What do you want to capture?</strong></p>
        <textarea name="content" rows="10" style="width: 100%; font-family: monospace;"></textarea>
        <br><br>
        <button type="submit" style="padding: 10px 20px;">Submit</button>
      </form>
    </body>
    </html>
  `);
});

// Handle submission
app.post('/submit', (req, res) => {
  const content = req.body.content;
  if (!content || content.trim() === '') {
    return res.send('Nothing to capture. <a href="/">Go back</a>');
  }

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filename = `captures/CAP-${timestamp}.txt`;
  const filepath = path.join(REPO_PATH, filename);

  // Ensure captures directory exists
  const capturesDir = path.join(REPO_PATH, 'captures');
  if (!fs.existsSync(capturesDir)) {
    fs.mkdirSync(capturesDir, { recursive: true });
  }

  // Write the capture
  fs.writeFileSync(filepath, `CAPTURE: ${timestamp}\n\n${content}\n`);

  // Git operations
  try {
    execSync(`git add "${filename}"`, { cwd: REPO_PATH });
    execSync(`git commit -m "Capture: ${timestamp}"`, { cwd: REPO_PATH });
    execSync('git push', { cwd: REPO_PATH });

    res.send(`
      <h1>Captured!</h1>
      <p>Your input has been saved and pushed to the repository.</p>
      <p>File: ${filename}</p>
      <a href="/">Submit another</a>
    `);
  } catch (error) {
    res.send(`
      <h1>Error</h1>
      <p>File was saved but git operations failed:</p>
      <pre>${error.message}</pre>
      <a href="/">Go back</a>
    `);
  }
});

app.listen(PORT, () => {
  console.log(`Futility's running on port ${PORT}`);
});

Press Ctrl+O, Enter, Ctrl+X to save and exit.


STEP 5.4: Start the server
──────────────────────────
pm2 start server.js --name futilitys
pm2 save
pm2 startup

(The last command will show you a command to copy and run - do that)


STEP 5.5: Update Caddy to proxy to your app
───────────────────────────────────────────
sudo nano /etc/caddy/Caddyfile

Replace contents with:

yourdomain.com {
    reverse_proxy localhost:3000
}

Save and restart:
sudo systemctl restart caddy


STEP 5.6: Test it!
──────────────────
1. Open https://yourdomain.com in your browser
2. You should see the intake form
3. Type something and click Submit
4. Check your GitHub repo - you should see a new file in captures/

───────────────────────────────────────────────────────────────────────────────
★ YOU'RE DONE WITH PHASE 5 WHEN:
  [ ] https://yourdomain.com shows your intake form
  [ ] Submitting text creates a commit in your GitHub repo
  [ ] You can see the captured file on GitHub
───────────────────────────────────────────────────────────────────────────────


===============================================================================
PHASE 6: ADD LOGIN PROTECTION
===============================================================================

Right now anyone can submit to your system. Let's add a simple PIN.

STEP 6.1: Update server.js with authentication
──────────────────────────────────────────────
nano ~/futilitys/server.js

Replace the entire file with a version that includes PIN auth
(This is getting long - in a real scenario, Claude Code would generate this)

For now, a simple approach - add this near the top after const PORT:

const VALID_PIN = '1234';  // Change this to your PIN

And wrap the routes in a check:

// Add this middleware before your routes
app.use((req, res, next) => {
  // Allow the login page
  if (req.path === '/login' || req.path === '/auth') {
    return next();
  }

  // Check for auth cookie
  const pin = req.headers.cookie?.match(/pin=(\d+)/)?.[1];
  if (pin !== VALID_PIN) {
    return res.redirect('/login');
  }
  next();
});

// Login page
app.get('/login', (req, res) => {
  res.send(`
    <form method="POST" action="/auth" style="margin: 100px auto; text-align: center;">
      <h1>Futility's</h1>
      <input type="password" name="pin" placeholder="Enter PIN" />
      <button type="submit">Enter</button>
    </form>
  `);
});

app.post('/auth', (req, res) => {
  if (req.body.pin === VALID_PIN) {
    res.setHeader('Set-Cookie', `pin=${VALID_PIN}; HttpOnly; Path=/`);
    res.redirect('/');
  } else {
    res.redirect('/login');
  }
});

Restart the server:
pm2 restart futilitys

───────────────────────────────────────────────────────────────────────────────
★ YOU'RE DONE WITH PHASE 6 WHEN:
  [ ] Going to https://yourdomain.com shows a PIN prompt
  [ ] Entering the correct PIN lets you in
  [ ] Wrong PIN keeps you on the login page
───────────────────────────────────────────────────────────────────────────────


===============================================================================
WHAT'S NEXT
===============================================================================

At this point you have:
  ✓ A server running in the cloud
  ✓ A domain with HTTPS
  ✓ A basic web interface
  ✓ Captures being saved to Git
  ✓ Simple PIN protection

The remaining phases from docs/ROADMAP.md are:
  - Phase 7: Add AI (claim extraction via Claude API)
  - Phase 8: Asset database and resolution
  - Phase 9: Verification gates and Confirm Screen
  - Phase 10: SSOT Explorer interface
  - Phase 11: Document/photo upload
  - Phase 12: Obsidian export
  - Phase 13: Mechanic feedback
  - Phase 14: Bulletin Board

Each of these involves more coding. At any point you can:
  1. Ask Claude Code to build the next feature
  2. Follow tutorials for each technology
  3. Hire a developer to help

The foundation is set. Everything from here is iteration.

===============================================================================
TROUBLESHOOTING
===============================================================================

CAN'T CONNECT VIA SSH:
  - Double-check the IP address
  - Make sure you're using the right SSH key
  - Check if firewall is blocking (in DigitalOcean, check "Networking" > "Firewall")

WEBSITE NOT LOADING:
  - Check if Caddy is running: sudo systemctl status caddy
  - Check if your app is running: pm2 status
  - Check Caddy logs: sudo journalctl -u caddy -f
  - Check app logs: pm2 logs futilitys

GIT PUSH FAILING:
  - Make sure deploy key has write access
  - Check if you're on a branch that allows pushes
  - Run: git remote -v to verify the remote URL

DOMAIN NOT RESOLVING:
  - DNS can take up to 48 hours (usually 5-30 min)
  - Use https://dnschecker.org to see propagation status
  - Make sure A record points to your droplet IP

===============================================================================
COMMANDS CHEAT SHEET
===============================================================================

CONNECT TO SERVER:
  ssh gondor@YOUR_IP_ADDRESS

RESTART YOUR APP:
  pm2 restart futilitys

VIEW APP LOGS:
  pm2 logs futilitys

RESTART CADDY (WEB SERVER):
  sudo systemctl restart caddy

UPDATE YOUR CODE FROM GITHUB:
  cd ~/futilitys-spec && git pull

CHECK DISK SPACE:
  df -h

CHECK MEMORY:
  free -h

CHECK WHAT'S RUNNING:
  pm2 status
  sudo systemctl status caddy

===============================================================================
END GAMEPLAN
===============================================================================
