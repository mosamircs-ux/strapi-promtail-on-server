# Strapi Promtail Log Shipper for Loki

A lightweight, automated setup to ship **Strapi PM2 logs** (and system logs) from a Linux VPS / EC2 server to a centralized **Grafana Loki** instance (e.g., hosted on Coolify, Grafana Cloud, or custom servers).

---

## 📌 Features

- 🚀 **Automated Installation**: Downloads, configures, and runs Promtail as a Systemd background service via a single script.
- 📜 **PM2 Log Scraping**: Automatically captures all stdout/stderr logs from PM2 processes located in `/home/ubuntu/.pm2/logs/*.log`.
- 🔍 **Log Pipeline Parsing**: Extracts timestamps, log levels (`info`, `warn`, `error`), and application names (`app_name`) for structured filtering in Grafana.
- 🛠️ **Management & Diagnostic Tools**: Includes verification scripts, position reset helpers, and a comprehensive LogQL cheat sheet.

---

## 📁 Repository Structure

| File / Script | Description |
| :--- | :--- |
| `install-promtail.sh` | Main installation bash script (downloads Promtail, writes config, configures & enables systemd service). |
| `promtail-config.yml` | Standalone Promtail configuration file template with custom regex pipeline stages. |
| `promtail.service` | Systemd unit service configuration file. |
| `verify-promtail.sh` | Diagnostic script to check Promtail health, active log targets, and metrics sending status. |
| `reset-promtail-positions.sh` | Script to reset log offset positions (`positions.yaml`) to re-ingest all logs from the beginning. |
| `logql-queries.md` | LogQL queries guide for Grafana exploration, dashboards, and alerts. |

---

## ⚙️ Prerequisites

Before installing, ensure your VPS meets the following criteria:
1. **OS**: Ubuntu / Debian Linux VPS (EC2, DigitalOcean, Hetzner, etc.).
2. **Permissions**: Sudo or Root access.
3. **Dependencies**: `curl`, `wget`, `unzip` installed (`sudo apt update && sudo apt install -y curl wget unzip`).
4. **Application Setup**: Strapi running under **PM2** on the server.
5. **Loki Endpoint**: A publicly accessible Grafana Loki push URL (e.g., `https://loki.yourdomain.com/loki/api/v1/push`).

---

## 🚀 How to Run & Deploy on VPS

### Step 1: Transfer Files to your VPS
SSH into your VPS and clone or upload this directory:
```bash
git clone <your-repository-url> strapi-promtail
cd strapi-promtail
```
*(Or upload the files directly using SCP or SFTP to `/tmp` or your home directory).*

### Step 2: Make Scripts Executable
Grant execution permissions to the bash scripts:
```bash
chmod +x *.sh
```

### Step 3: Configure Variables (Optional / Recommended)
Open `install-promtail.sh` and verify or update the default variables at the top of the file:
```bash
nano install-promtail.sh
```
Adjust the following values if necessary:
```bash
PROMTAIL_VERSION="2.9.3"
LOKI_ENDPOINT="https://your-loki-instance-domain.com" # Replace with your Loki endpoint
PM2_LOGS_PATH="/home/ubuntu/.pm2/logs"                # Path to your PM2 logs directory
```

### Step 4: Run the Installer
Execute the installation script with `sudo`:
```bash
sudo ./install-promtail.sh
```

The script will automatically perform the following steps:
1. Download Promtail v2.9.3 binary.
2. Install Promtail into `/usr/local/bin/promtail`.
3. Create `/etc/promtail/config.yml` with scraping rules for PM2 and syslog.
4. Set up `/etc/systemd/system/promtail.service`.
5. Enable and start the Promtail service automatically.

---

## 🩺 Verification & Management

### Verify Promtail Status & Health
Run the included verification script to test if Promtail is actively scraping logs and sending them to Loki:
```bash
sudo ./verify-promtail.sh
```

### Useful Service Commands
- **Check service status**:
  ```bash
  sudo systemctl status promtail
  ```
- **View live Promtail logs**:
  ```bash
  sudo journalctl -u promtail -f
  ```
- **Check Promtail HTTP ready endpoint**:
  ```bash
  curl http://localhost:9080/ready
  ```
- **Restart Promtail**:
  ```bash
  sudo systemctl restart promtail
  ```

### Resetting Log Ingestion Positions
Promtail tracks which lines it has already sent in `/var/lib/promtail/positions.yaml`. If you need to re-read and re-send all existing logs from the beginning, run:
```bash
sudo ./reset-promtail-positions.sh
```

---

## 📊 Viewing Logs in Grafana

1. Open your **Grafana** interface.
2. Navigate to **Explore** (compass icon in the sidebar).
3. Select your **Loki** data source.
4. Run LogQL queries to view your Strapi logs!

### Example Queries
- **View all Strapi logs**:
  ```logql
  {job="strapi"}
  ```
- **View Errors only**:
  ```logql
  {job="strapi", level="error"}
  ```
- **Filter by Application Name**:
  ```logql
  {job="strapi", app_name="strapi-app"}
  ```

> 📖 For advanced queries, error rate metrics, dashboard panel setup, and alert rules, refer to [logql-queries.md](logql-queries.md).

---

## 📄 License

MIT License. Feel free to modify and adapt for your deployment environment!
