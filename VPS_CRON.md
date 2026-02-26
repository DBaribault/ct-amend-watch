# Run Every 5 Minutes on a VPS

This is the fastest path to run the watcher even when your own computer is off.

## 1) Provision a small Linux VPS

Ubuntu 22.04/24.04 is fine.

## 2) SSH in and install base packages

```bash
sudo apt-get update
sudo apt-get install -y git python3 python3-venv python3-pip
```

## 3) Clone and set up the app

```bash
cd ~
git clone <your-repo-url> ct-amend-watch
cd ct-amend-watch

python3 -m venv .venv
./.venv/bin/pip install --upgrade pip
./.venv/bin/pip install -r requirements.txt
```

## 4) Install Playwright system deps + Chromium

```bash
sudo ./.venv/bin/python -m playwright install-deps chromium
./.venv/bin/python -m playwright install chromium
```

## 5) Create your environment file

```bash
cp .env.example .env
nano .env
```

Set:

```dotenv
TELEGRAM_BOT_TOKEN=...
TELEGRAM_CHAT_ID=...
CT_SESSION_YEAR=2026
CT_REQUIRE_TELEGRAM=1
CT_AMEND_DEBUG=0
```

Lock it down:

```bash
chmod 600 .env
```

## 6) Test one manual run

```bash
./.venv/bin/python watch_amend.py
```

If this succeeds, scheduling will work too.

## 7) Make cron runner executable

```bash
chmod +x scripts/run_cron.sh
```

## 8) Add cron job (every 5 minutes)

Open crontab:

```bash
crontab -e
```

Add:

```cron
*/5 * * * * /home/<your-user>/ct-amend-watch/scripts/run_cron.sh
```

Optional timezone for cron entries:

```cron
CRON_TZ=America/New_York
*/5 * * * * /home/<your-user>/ct-amend-watch/scripts/run_cron.sh
```

## 9) Check logs

```bash
tail -f ~/ct-amend-watch/logs/watch_amend.log
```

## Notes

- The wrapper uses `flock` so overlapping runs are skipped.
- State is stored in `state.json`, so it survives reboots.
- This runs independently of your personal computer.
