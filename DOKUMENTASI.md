# Dokumentasi Sistem Monitoring Server

## Daftar Isi
1. [Ringkasan](#ringkasan)
2. [Tutorial Instalasi](#tutorial-instalasi)
3. [Komponen yang Terinstal](#komponen-yang-terinstal)
4. [Akses Web GUI](#akses-web-gui)
5. [Akses API](#akses-api)
6. [Contoh Penggunaan API](#contoh-penggunaan-api)
7. [Query Prometheus yang Berguna](#query-prometheus-yang-berguna)
8. [Manajemen Layanan](#manajemen-layanan)
9. [Troubleshooting](#troubleshooting)

---

## Ringkasan

Sistem monitoring ini terdiri dari:
- **Prometheus** (monitoring agent) - Mengumpulkan dan menyimpan metrics
- **Node Exporter** - Mengeksport metrics sistem (CPU, Memory, Disk, Network)
- **Grafana** (monitoring station) - Dashboard visualisasi berbasis web

### Arsitektur
```
┌─────────────────┐
│  Node Exporter  │ --> Eksport metrics sistem (port 9100)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Prometheus    │ --> Scrape & store metrics (port 9090)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Grafana      │ --> Visualisasi web (port 3000)
└─────────────────┘
```

---

## Tutorial Instalasi

> **Catatan Penting tentang Path:**
> - Simbol `~` merepresentasikan home directory user Anda (misalnya: `/home/username`)
> - Ganti `<username>` atau `<your-username>` dengan username Linux Anda
> - Ganti `<your-hostname>` dengan hostname server Anda (cek dengan command: `hostname`)
> - Semua command diasumsikan dijalankan sebagai user biasa, bukan root (kecuali yang menggunakan `sudo`)

### Persiapan Awal

```bash
# Buat direktori untuk monitoring (di home directory user Anda)
mkdir -p ~/monitoring
cd ~/monitoring

# Atau gunakan path absolut (ganti 'debian' dengan username Anda)
# mkdir -p /home/<username>/monitoring
# cd /home/<username>/monitoring
```

### 1. Instalasi Prometheus

**Step 1: Download Prometheus**

```bash
# Download Prometheus versi 2.48.0 (pastikan Anda di direktori monitoring)
cd ~/monitoring
wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz
```

**Step 2: Extract Archive**

```bash
# Extract file
tar xvfz prometheus-2.48.0.linux-amd64.tar.gz
```

**Step 3: Konfigurasi Prometheus**

```bash
# Edit file konfigurasi
cd prometheus-2.48.0.linux-amd64
nano prometheus.yml
```

Ubah atau pastikan konfigurasi seperti berikut:

```yaml
# my global config
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# Scrape configurations
scrape_configs:
  # Prometheus self-monitoring
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  # Node Exporter untuk metrics sistem
  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
        labels:
          instance: "<your-hostname>"  # Ganti dengan hostname Anda (jalankan: hostname)
          hostname: "<your-hostname>"  # Ganti dengan hostname Anda
```

**Step 4: Jalankan Prometheus**

```bash
# Jalankan Prometheus di background
cd ~/monitoring/prometheus-2.48.0.linux-amd64
./prometheus --config.file=prometheus.yml &
```

**Step 5: Verifikasi**

```bash
# Cek apakah Prometheus berjalan
curl http://localhost:9090/-/healthy

# Akses Web UI
# http://<IP-SERVER>:9090
```

### 2. Instalasi Node Exporter

**Step 1: Download Node Exporter**

```bash
# Download Node Exporter versi 1.7.0
cd ~/monitoring
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
```

**Step 2: Extract Archive**

```bash
# Extract file
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
```

**Step 3: Jalankan Node Exporter**

```bash
# Jalankan Node Exporter di background
cd ~/monitoring/node_exporter-1.7.0.linux-amd64
./node_exporter &
```

**Step 4: Verifikasi**

```bash
# Cek apakah Node Exporter berjalan
curl http://localhost:9100/metrics | head -20

# Cek apakah Prometheus sudah scraping
curl http://localhost:9090/api/v1/targets
```

### 3. Instalasi Grafana

**Step 1: Install Prerequisites**

```bash
# Update sistem dan install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common wget
```

**Step 2: Tambahkan Repository Grafana**

```bash
# Tambahkan GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Tambahkan repository
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
```

**Step 3: Install Grafana**

```bash
# Update dan install Grafana
sudo apt-get update
sudo apt-get install -y grafana
```

**Step 4: Start Grafana Service**

```bash
# Enable dan start Grafana
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Cek status
sudo systemctl status grafana-server
```

**Step 5: Verifikasi**

```bash
# Cek apakah Grafana berjalan
curl http://localhost:3000/api/health

# Akses Web UI
# http://<IP-SERVER>:3000
# Login: admin / admin
```

### 4. Konfigurasi Grafana (First Time Setup)

**Step 1: Login ke Grafana**

1. Buka browser: `http://<IP-SERVER>:3000`
2. Login dengan:
   - Username: `admin`
   - Password: `admin`
3. Ganti password (opsional, bisa skip)

**Step 2: Tambahkan Prometheus Data Source**

1. Klik icon **Configuration** (⚙️) di sidebar kiri
2. Pilih **Data Sources**
3. Klik **Add data source**
4. Pilih **Prometheus**
5. Konfigurasi:
   - **Name**: `Prometheus`
   - **URL**: `http://localhost:9090`
   - **Access**: `Server (default)`
6. Klik **Save & Test** (harus muncul "Data source is working")

**Step 3: Import Dashboard**

1. Klik icon **+** di sidebar
2. Pilih **Import**
3. Masukkan Dashboard ID: `1860` (Node Exporter Full)
4. Klik **Load**
5. Pilih **Prometheus** sebagai data source
6. Klik **Import**

Dashboard akan langsung menampilkan metrics sistem!

### 5. Membuat Services Systemd (Opsional - Auto Start)

Agar Prometheus dan Node Exporter auto-start saat reboot:

**Node Exporter Service:**

```bash
# Buat service file
sudo nano /etc/systemd/system/node_exporter.service
```

Isi dengan:

```ini
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
User=debian
ExecStart=/home/debian/monitoring/node_exporter-1.7.0.linux-amd64/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

**Prometheus Service:**

```bash
# Buat service file
sudo nano /etc/systemd/system/prometheus.service
```

Isi dengan:

```ini
[Unit]
Description=Prometheus
After=network.target

[Service]
Type=simple
User=debian
ExecStart=/home/debian/monitoring/prometheus-2.48.0.linux-amd64/prometheus --config.file=/home/debian/monitoring/prometheus-2.48.0.linux-amd64/prometheus.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

**Aktifkan Services:**

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable services
sudo systemctl enable node_exporter
sudo systemctl enable prometheus

# Start services
sudo systemctl start node_exporter
sudo systemctl start prometheus

# Cek status
sudo systemctl status node_exporter
sudo systemctl status prometheus
```

### 6. Verifikasi Instalasi Lengkap

**Cek Semua Port:**

```bash
# Cek port yang listening
sudo ss -tlnp | grep -E '9090|9100|3000'

# Output yang diharapkan:
# 0.0.0.0:9090 ... prometheus
# 0.0.0.0:9100 ... node_exporter
# 0.0.0.0:3000 ... grafana-server
```

**Cek Semua Services:**

```bash
# Prometheus
curl http://localhost:9090/-/healthy

# Node Exporter
curl http://localhost:9100/metrics | head -5

# Grafana
curl http://localhost:3000/api/health

# Cek targets Prometheus
curl http://localhost:9090/api/v1/targets | python3 -m json.tool
```

### 7. Setup Firewall (Opsional)

Jika menggunakan UFW:

```bash
# Allow port Prometheus
sudo ufw allow 9090/tcp

# Allow port Node Exporter (jika perlu akses eksternal)
sudo ufw allow 9100/tcp

# Allow port Grafana
sudo ufw allow 3000/tcp

# Reload firewall
sudo ufw reload

# Cek status
sudo ufw status
```

### 8. Instalasi API Examples

**Install Python Dependencies:**

```bash
# Install requests library
pip3 install requests
```

**Test API Examples:**

```bash
# Test Prometheus API
cd ~/monitoring/api_examples
python3 prometheus_api_example.py

# Test Grafana API
python3 grafana_api_example.py

# Test curl examples
./curl_examples.sh
```

### Troubleshooting Instalasi

**Problem: wget command not found**
```bash
sudo apt-get install wget
```

**Problem: Permission denied saat menjalankan service**
```bash
# Pastikan binary executable
chmod +x ~/monitoring/prometheus-2.48.0.linux-amd64/prometheus
chmod +x ~/monitoring/node_exporter-1.7.0.linux-amd64/node_exporter
```

**Problem: Port already in use**
```bash
# Cek process yang menggunakan port
sudo lsof -i :9090
sudo lsof -i :9100
sudo lsof -i :3000

# Kill process jika perlu
sudo kill -9 <PID>
```

**Problem: Grafana tidak bisa connect ke Prometheus**
```bash
# Pastikan Prometheus berjalan
curl http://localhost:9090/-/healthy

# Pastikan URL di Grafana: http://localhost:9090 (bukan IP)
# Restart Grafana
sudo systemctl restart grafana-server
```

### Ringkasan Struktur File Setelah Instalasi

```
~/monitoring/  (atau /home/<username>/monitoring/)
├── prometheus-2.48.0.linux-amd64/
│   ├── prometheus                    # Binary Prometheus
│   ├── promtool                      # Tool Prometheus
│   ├── prometheus.yml                # Config file
│   ├── consoles/
│   └── console_libraries/
├── node_exporter-1.7.0.linux-amd64/
│   ├── node_exporter                 # Binary Node Exporter
│   ├── LICENSE
│   └── NOTICE
├── api_examples/
│   ├── prometheus_api_example.py     # Python example
│   ├── grafana_api_example.py        # Python example
│   └── curl_examples.sh              # Shell example
├── prometheus-2.48.0.linux-amd64.tar.gz
├── node_exporter-1.7.0.linux-amd64.tar.gz
├── DOKUMENTASI.md                    # File ini
├── HOSTNAME_CONFIG.md                # Config hostname
└── README.md                         # Quick start
```

### Instalasi Selesai! ✅

Sekarang Anda memiliki:
- ✅ Prometheus berjalan di port 9090
- ✅ Node Exporter berjalan di port 9100
- ✅ Grafana berjalan di port 3000
- ✅ Dashboard siap digunakan

**Next Steps:**
1. Akses Grafana: `http://<IP-SERVER>:3000`
2. Import dashboard ID 1860 atau 11074
3. Explore metrics dan buat custom dashboard
4. Setup alerting (opsional)
5. Gunakan API untuk integrasi aplikasi

---

## Komponen yang Terinstal

### 1. Prometheus (Monitoring Agent)
- **Lokasi**: `~/monitoring/prometheus-2.48.0.linux-amd64/`
- **Port**: 9090
- **Fungsi**: Scraping metrics dari berbagai target, menyimpan time-series data
- **Konfigurasi**: `~/monitoring/prometheus-2.48.0.linux-amd64/prometheus.yml`
- **Hostname**: Node exporter dikonfigurasi dengan hostname server Anda

### 2. Node Exporter
- **Lokasi**: `~/monitoring/node_exporter-1.7.0.linux-amd64/`
- **Port**: 9100
- **Fungsi**: Mengeksport metrics hardware dan OS (CPU, memory, disk, network)

### 3. Grafana (Monitoring Station)
- **Lokasi**: `/usr/share/grafana/`
- **Port**: 3000
- **Fungsi**: Dashboard visualisasi dan analisis data monitoring
- **Service**: `grafana-server.service` (systemd)

---

## Akses Web GUI

### 1. Prometheus Web UI
**URL**: `http://<IP-SERVER>:9090`

**Fitur**:
- Query interface untuk PromQL
- Graph untuk visualisasi quick metrics
- Target status monitoring
- Alert manager
- Configuration viewer

**Cara Menggunakan**:
1. Buka browser dan akses `http://localhost:9090` atau `http://<IP-SERVER>:9090`
2. Klik **Graph** untuk membuat query
3. Masukkan query PromQL, contoh:
   ```promql
   rate(node_cpu_seconds_total[5m])
   ```
4. Klik **Execute** untuk melihat hasil

### 2. Grafana Web Dashboard
**URL**: `http://<IP-SERVER>:3000`

**Default Credentials**:
- Username: `admin`
- Password: `admin`

**Setup Awal**:

1. **Login ke Grafana**:
   - Buka `http://localhost:3000`
   - Login dengan credentials default
   - Anda akan diminta untuk mengganti password (opsional pada first login)

2. **Menambahkan Prometheus sebagai Data Source**:
   - Klik menu **Configuration** (⚙️) > **Data Sources**
   - Klik **Add data source**
   - Pilih **Prometheus**
   - Konfigurasi:
     - Name: `Prometheus`
     - URL: `http://localhost:9090`
     - Access: `Server (default)`
   - Klik **Save & Test**

3. **Membuat Dashboard**:
   - Klik **Create** (+) > **Dashboard**
   - Klik **Add new panel**
   - Di Query editor, pilih data source **Prometheus**
   - Masukkan query, contoh:
     ```promql
     100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
     ```
   - Atur visualisasi (Graph, Gauge, Stat, dll.)
   - Klik **Apply**

4. **Import Dashboard Siap Pakai**:
   - Klik **Create** (+) > **Import**
   - Masukkan Dashboard ID dari [Grafana Dashboard Library](https://grafana.com/grafana/dashboards/):
     - Node Exporter Full: `1860`
     - Node Exporter for Prometheus: `11074`
   - Klik **Load**
   - Pilih Prometheus data source
   - Klik **Import**

---

## Akses API

### 1. Prometheus API

**Base URL**: `http://<IP-SERVER>:9090/api/v1/`

#### Endpoints Utama:

##### a. Instant Query
Query metrics pada satu waktu tertentu.

```bash
GET /api/v1/query?query=<promql-query>&time=<timestamp>
```

Contoh:
```bash
curl "http://localhost:9090/api/v1/query?query=up"
```

##### b. Range Query
Query metrics dalam rentang waktu.

```bash
GET /api/v1/query_range?query=<promql>&start=<timestamp>&end=<timestamp>&step=<duration>
```

Contoh:
```bash
curl "http://localhost:9090/api/v1/query_range?query=up&start=1699000000&end=1699003600&step=15s"
```

##### c. Targets
Melihat status semua target yang di-scrape.

```bash
GET /api/v1/targets
```

Contoh:
```bash
curl http://localhost:9090/api/v1/targets
```

##### d. Series
Mencari time series berdasarkan label.

```bash
GET /api/v1/series?match[]=<series-selector>
```

Contoh:
```bash
curl "http://localhost:9090/api/v1/series?match[]=up"
```

##### e. Labels
Mendapatkan daftar label names.

```bash
GET /api/v1/labels
```

##### f. Label Values
Mendapatkan nilai dari label tertentu.

```bash
GET /api/v1/label/<label_name>/values
```

### 2. Grafana API

**Base URL**: `http://<IP-SERVER>:3000/api/`

**Authentication**: Grafana API memerlukan authentication. Ada 2 cara:
1. Basic Auth: `username:password`
2. API Key (lebih aman untuk production)

#### Membuat API Key:
1. Login ke Grafana Web UI
2. Klik **Configuration** (⚙️) > **API Keys**
3. Klik **Add API Key**
4. Beri nama dan pilih role (Admin/Editor/Viewer)
5. Klik **Add**
6. Copy API key yang dihasilkan

#### Endpoints Utama:

##### a. Health Check
```bash
GET /api/health
```

Contoh:
```bash
curl http://localhost:3000/api/health
```

##### b. Data Sources
List semua data sources:
```bash
GET /api/datasources
```

Contoh dengan Basic Auth:
```bash
curl -u admin:admin http://localhost:3000/api/datasources
```

Contoh dengan API Key:
```bash
curl -H "Authorization: Bearer <your-api-key>" http://localhost:3000/api/datasources
```

##### c. Dashboards
List semua dashboards:
```bash
GET /api/search
```

Get dashboard by UID:
```bash
GET /api/dashboards/uid/<dashboard-uid>
```

Contoh:
```bash
curl -u admin:admin http://localhost:3000/api/search
```

##### d. Query Data Source
Query data dari data source:
```bash
POST /api/ds/query
Content-Type: application/json

{
  "queries": [{
    "datasourceId": 1,
    "expr": "up",
    "refId": "A"
  }]
}
```

##### e. Organizations
Get current organization:
```bash
GET /api/org
```

##### f. Users
Get current user:
```bash
GET /api/user
```

---

## Contoh Penggunaan API

### 1. Python Examples

Anda dapat menemukan contoh lengkap di:
- `~/monitoring/api_examples/prometheus_api_example.py`
- `~/monitoring/api_examples/grafana_api_example.py`

#### Menjalankan Prometheus API Example:
```bash
cd ~/monitoring/api_examples
python3 prometheus_api_example.py
```

#### Menjalankan Grafana API Example:
```bash
cd ~/monitoring/api_examples
python3 grafana_api_example.py
```

#### Install Dependencies:
```bash
pip3 install requests
```

#### Contoh Kode Python - Prometheus:

```python
import requests

PROMETHEUS_URL = "http://localhost:9090"

# Query CPU usage
def get_cpu_usage():
    query = '100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'
    url = f"{PROMETHEUS_URL}/api/v1/query"
    params = {'query': query}
    
    response = requests.get(url, params=params)
    data = response.json()
    
    if data['status'] == 'success':
        return data['data']['result']
    return None

# Query dengan filter hostname
def get_cpu_by_hostname(hostname):
    query = f'100 - (avg by(hostname) (irate(node_cpu_seconds_total{{hostname="{hostname}",mode="idle"}}[5m])) * 100)'
    url = f"{PROMETHEUS_URL}/api/v1/query"
    params = {'query': query}
    
    response = requests.get(url, params=params)
    data = response.json()
    
    if data['status'] == 'success':
        return data['data']['result']
    return None

# Menggunakan fungsi
result = get_cpu_usage()
print(result)

# Query berdasarkan hostname
result_hostname = get_cpu_by_hostname('matthew-ganteng')
print(result_hostname)
```

#### Contoh Kode Python - Grafana:

```python
import requests

GRAFANA_URL = "http://localhost:3000"
API_KEY = "your-api-key-here"  # atau gunakan basic auth

# Get all dashboards
def get_dashboards():
    url = f"{GRAFANA_URL}/api/search"
    headers = {"Authorization": f"Bearer {API_KEY}"}
    # Atau dengan basic auth:
    # auth = ("admin", "admin")
    
    response = requests.get(url, headers=headers)
    # Atau: response = requests.get(url, auth=auth)
    
    return response.json()

dashboards = get_dashboards()
print(dashboards)
```

### 2. cURL Examples

File contoh: `~/monitoring/api_examples/curl_examples.sh`

Menjalankan:
```bash
cd ~/monitoring/api_examples
./curl_examples.sh
```

#### Contoh cURL - Prometheus:

```bash
# 1. Query instant - CPU usage
curl "http://localhost:9090/api/v1/query?query=100-(avg%20by(instance)%20(irate(node_cpu_seconds_total{mode=\"idle\"}[5m]))*100)"

# 2. Query instant - Memory usage
curl "http://localhost:9090/api/v1/query?query=(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)/node_memory_MemTotal_bytes*100"

# 3. Range query - CPU selama 1 jam terakhir
END=$(date +%s)
START=$((END - 3600))
curl "http://localhost:9090/api/v1/query_range?query=up&start=${START}&end=${END}&step=1m"

# 4. Cek status targets
curl http://localhost:9090/api/v1/targets

# 5. List semua metrics
curl http://localhost:9090/api/v1/label/__name__/values
```

#### Contoh cURL - Grafana:

```bash
# 1. Health check
curl http://localhost:3000/api/health

# 2. Get data sources (dengan basic auth)
curl -u admin:admin http://localhost:3000/api/datasources

# 3. Get dashboards
curl -u admin:admin http://localhost:3000/api/search

# 4. Get specific dashboard
curl -u admin:admin http://localhost:3000/api/dashboards/uid/<dashboard-uid>

# 5. Create API Key programmatically
curl -X POST -H "Content-Type: application/json" -u admin:admin \
  -d '{"name":"my-api-key","role":"Admin"}' \
  http://localhost:3000/api/auth/keys

# 6. Query dengan API Key
curl -H "Authorization: Bearer <your-api-key>" \
  http://localhost:3000/api/datasources
```

### 3. JavaScript/Node.js Example

```javascript
const axios = require('axios');

const PROMETHEUS_URL = 'http://localhost:9090';

async function getCPUUsage() {
    const query = '100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)';
    
    try {
        const response = await axios.get(`${PROMETHEUS_URL}/api/v1/query`, {
            params: { query }
        });
        
        return response.data.data.result;
    } catch (error) {
        console.error('Error:', error);
    }
}

getCPUUsage().then(data => console.log(data));
```

---

## Query Prometheus yang Berguna

### 1. CPU Metrics

```promql
# CPU usage per core
100 - (avg by(cpu) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Overall CPU usage
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# CPU usage by mode
rate(node_cpu_seconds_total[5m])

# System load average
node_load1
node_load5
node_load15
```

### 2. Memory Metrics

```promql
# Memory usage percentage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Available memory
node_memory_MemAvailable_bytes

# Total memory
node_memory_MemTotal_bytes

# Memory usage in GB
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / 1024 / 1024 / 1024

# Swap usage
(node_memory_SwapTotal_bytes - node_memory_SwapFree_bytes) / node_memory_SwapTotal_bytes * 100
```

### 3. Disk Metrics

```promql
# Disk usage percentage per mountpoint
(node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100

# Disk available space in GB
node_filesystem_avail_bytes / 1024 / 1024 / 1024

# Disk I/O rate (read)
rate(node_disk_read_bytes_total[5m])

# Disk I/O rate (write)
rate(node_disk_written_bytes_total[5m])

# Disk I/O operations per second
rate(node_disk_reads_completed_total[5m])
rate(node_disk_writes_completed_total[5m])
```

### 4. Network Metrics

```promql
# Network receive rate (bytes/sec)
rate(node_network_receive_bytes_total[5m])

# Network transmit rate (bytes/sec)
rate(node_network_transmit_bytes_total[5m])

# Network receive rate (Mbps)
rate(node_network_receive_bytes_total[5m]) * 8 / 1024 / 1024

# Network errors
rate(node_network_receive_errs_total[5m])
rate(node_network_transmit_errs_total[5m])

# Total connections
node_netstat_Tcp_CurrEstab
```

### 5. System Metrics

```promql
# Uptime
node_time_seconds - node_boot_time_seconds

# Number of CPUs
count(node_cpu_seconds_total{mode="idle"})

# File descriptors used
process_open_fds

# Context switches
rate(node_context_switches_total[5m])
```

---

## Manajemen Layanan

### Prometheus & Node Exporter (Running as background process)

#### Start Services:
```bash
# Start Node Exporter
cd ~/monitoring/node_exporter-1.7.0.linux-amd64
./node_exporter &

# Start Prometheus
cd ~/monitoring/prometheus-2.48.0.linux-amd64
./prometheus --config.file=prometheus.yml &
```

#### Check if Running:
```bash
# Check Node Exporter
curl http://localhost:9100/metrics

# Check Prometheus
curl http://localhost:9090/api/v1/status/config

# Or check process
ps aux | grep node_exporter
ps aux | grep prometheus
```

#### Stop Services:
```bash
# Find process ID
ps aux | grep node_exporter
ps aux | grep prometheus

# Kill process
kill <PID>
# or
pkill -f node_exporter
pkill -f prometheus
```

#### Membuat systemd service (Opsional, untuk auto-start):

**Node Exporter Service**:
```bash
sudo nano /etc/systemd/system/node_exporter.service
```

Isi dengan:
```ini
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
User=debian
ExecStart=/home/debian/monitoring/node_exporter-1.7.0.linux-amd64/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

**Prometheus Service**:
```bash
sudo nano /etc/systemd/system/prometheus.service
```

Isi dengan:
```ini
[Unit]
Description=Prometheus
After=network.target

[Service]
Type=simple
User=debian
ExecStart=/home/debian/monitoring/prometheus-2.48.0.linux-amd64/prometheus --config.file=/home/debian/monitoring/prometheus-2.48.0.linux-amd64/prometheus.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Kemudian:
```bash
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl enable prometheus
sudo systemctl start node_exporter
sudo systemctl start prometheus
```

### Grafana (systemd service)

```bash
# Start Grafana
sudo systemctl start grafana-server

# Stop Grafana
sudo systemctl stop grafana-server

# Restart Grafana
sudo systemctl restart grafana-server

# Check status
sudo systemctl status grafana-server

# Enable auto-start on boot
sudo systemctl enable grafana-server

# View logs
sudo journalctl -u grafana-server -f
```

### Check All Services:
```bash
# Check if ports are listening
sudo netstat -tlnp | grep -E '9090|9100|3000'
# or
sudo ss -tlnp | grep -E '9090|9100|3000'
```

---

## Troubleshooting

### 1. Prometheus tidak bisa diakses

**Problem**: `curl: (7) Failed to connect to localhost port 9090`

**Solution**:
```bash
# Check if Prometheus is running
ps aux | grep prometheus

# If not running, start it
cd ~/monitoring/prometheus-2.48.0.linux-amd64
./prometheus --config.file=prometheus.yml &

# Check logs (jika ada)
tail -f ~/monitoring/prometheus-2.48.0.linux-amd64/*.log
```

### 2. Node Exporter tidak memberikan metrics

**Problem**: Prometheus tidak bisa scrape metrics dari Node Exporter

**Solution**:
```bash
# Check if Node Exporter is running
curl http://localhost:9100/metrics

# If not working, restart Node Exporter
pkill -f node_exporter
cd ~/monitoring/node_exporter-1.7.0.linux-amd64
./node_exporter &

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets
```

### 3. Grafana tidak bisa login

**Problem**: Login dengan admin/admin gagal

**Solution**:
```bash
# Reset admin password
sudo grafana-cli admin reset-admin-password newpassword

# Check Grafana logs
sudo journalctl -u grafana-server -n 100
```

### 4. Grafana tidak bisa connect ke Prometheus

**Problem**: "Bad Gateway" atau connection error di data source

**Solution**:
1. Pastikan Prometheus berjalan:
   ```bash
   curl http://localhost:9090/api/v1/status/config
   ```

2. Cek URL data source di Grafana:
   - Harus: `http://localhost:9090`
   - Bukan: `http://127.0.0.1:9090` atau IP lain

3. Restart Grafana:
   ```bash
   sudo systemctl restart grafana-server
   ```

### 5. Port sudah digunakan

**Problem**: `bind: address already in use`

**Solution**:
```bash
# Find process using the port
sudo lsof -i :9090  # untuk Prometheus
sudo lsof -i :9100  # untuk Node Exporter
sudo lsof -i :3000  # untuk Grafana

# Kill the process
sudo kill -9 <PID>
```

### 6. API returns empty data

**Problem**: API response berhasil tapi data kosong

**Solution**:
1. Pastikan data scraping berjalan:
   ```bash
   curl http://localhost:9090/api/v1/targets
   ```

2. Periksa query syntax:
   ```bash
   # Test query di Prometheus web UI dulu
   # http://localhost:9090/graph
   ```

3. Periksa time range:
   ```bash
   # Pastikan time range mencakup data yang ada
   curl "http://localhost:9090/api/v1/query?query=up&time=$(date +%s)"
   ```

### 7. Firewall blocking access

**Problem**: Tidak bisa akses dari komputer lain

**Solution**:
```bash
# Allow ports di firewall
sudo ufw allow 9090/tcp  # Prometheus
sudo ufw allow 9100/tcp  # Node Exporter
sudo ufw allow 3000/tcp  # Grafana

# Check firewall status
sudo ufw status
```

---

## Tips Keamanan

### 1. Ganti Default Password Grafana
```bash
# Via Web UI: Configuration > Users > admin > Change Password
# Via CLI:
sudo grafana-cli admin reset-admin-password <new-password>
```

### 2. Gunakan API Key untuk Grafana
Jangan gunakan basic auth untuk production. Buat API Key dengan permissions terbatas.

### 3. Aktifkan Authentication untuk Prometheus
Edit prometheus.yml dan tambahkan basic auth atau gunakan reverse proxy (nginx/apache) dengan authentication.

### 4. Batasi Access dengan Firewall
```bash
# Hanya izinkan dari IP tertentu
sudo ufw allow from 192.168.1.0/24 to any port 9090
sudo ufw allow from 192.168.1.0/24 to any port 3000
```

### 5. Gunakan HTTPS
Setup reverse proxy (nginx) dengan SSL certificate untuk akses production.

---

## Referensi

### Dokumentasi Official:
- **Prometheus**: https://prometheus.io/docs/
- **Prometheus API**: https://prometheus.io/docs/prometheus/latest/querying/api/
- **Node Exporter**: https://github.com/prometheus/node_exporter
- **Grafana**: https://grafana.com/docs/
- **Grafana API**: https://grafana.com/docs/grafana/latest/developers/http_api/

### Grafana Dashboard Library:
- https://grafana.com/grafana/dashboards/

### PromQL Guide:
- https://prometheus.io/docs/prometheus/latest/querying/basics/

---

## Kesimpulan

Anda sekarang memiliki sistem monitoring yang lengkap dengan:
- ✅ Prometheus sebagai monitoring agent (port 9090)
- ✅ Node Exporter untuk system metrics (port 9100)
- ✅ Grafana untuk web dashboard (port 3000)
- ✅ API yang dapat diakses oleh program lain
- ✅ Contoh kode untuk Python dan shell script

Untuk memulai:
1. Akses Grafana di `http://<IP-SERVER>:3000`
2. Login dengan admin/admin
3. Tambahkan Prometheus sebagai data source
4. Import dashboard atau buat custom dashboard
5. Gunakan API untuk integrasi dengan aplikasi lain

Selamat memonitor! 🚀
