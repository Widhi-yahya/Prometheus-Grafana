# Quick Start Guide - Monitoring System

## ✅ Status Layanan

Semua layanan monitoring telah terinstal dan berjalan:

- **Prometheus** (Monitoring Agent): ✅ Running on port 9090
- **Node Exporter** (System Metrics): ✅ Running on port 9100  
- **Grafana** (Web Dashboard): ✅ Running on port 3000

## 🌐 Akses Web GUI

### Prometheus
- **URL**: http://10.34.100.99:9090
- **Fungsi**: Query metrics, lihat targets, testing PromQL

### Grafana (Dashboard Utama)
- **URL**: http://10.34.100.99:3000
- **Username**: `admin`
- **Password**: `admin`
- **Fungsi**: Visualisasi dashboard, grafik, monitoring lengkap

### Node Exporter
- **URL**: http://10.34.100.99:9100/metrics
- **Fungsi**: Raw metrics dari sistem

## 🔧 Setup Grafana (First Time)

1. **Login ke Grafana**
   ```
   URL: http://10.34.100.99:3000
   Username: admin
   Password: admin
   ```

2. **Tambah Data Source Prometheus**
   - Klik ⚙️ Configuration → Data Sources
   - Klik "Add data source"
   - Pilih "Prometheus"
   - URL: `http://localhost:9090`
   - Klik "Save & Test"

3. **Import Dashboard**
   - Klik ➕ Create → Import
   - Masukkan ID: `1860` (Node Exporter Full)
   - Klik "Load"
   - Pilih Prometheus data source
   - Klik "Import"

## 📊 API Endpoints

### Prometheus API
```bash
# Base URL
http://10.34.100.99:9090/api/v1/

# Contoh query CPU usage
curl "http://10.34.100.99:9090/api/v1/query?query=100-(avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m]))*100)"

# Contoh query Memory usage
curl "http://10.34.100.99:9090/api/v1/query?query=(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)/node_memory_MemTotal_bytes*100"
```

### Grafana API
```bash
# Health check
curl http://10.34.100.99:3000/api/health

# List data sources (dengan auth)
curl -u admin:admin http://10.34.100.99:3000/api/datasources

# List dashboards
curl -u admin:admin http://10.34.100.99:3000/api/search
```

## 💻 Contoh Program

### Python
```bash
cd /home/debian/monitoring/api_examples
pip3 install requests
python3 prometheus_api_example.py
python3 grafana_api_example.py
```

### Shell Script
```bash
cd /home/debian/monitoring/api_examples
./curl_examples.sh
```

## 📚 Dokumentasi Lengkap

Baca dokumentasi lengkap di: `/home/debian/monitoring/DOKUMENTASI.md`

Atau:
```bash
cat /home/debian/monitoring/DOKUMENTASI.md
```

## 🚀 Next Steps

1. Akses Grafana dan setup data source
2. Import dashboard (ID: 1860 atau 11074)
3. Buat dashboard custom sesuai kebutuhan
4. Gunakan API untuk integrasi dengan aplikasi
5. Setup alert notifications (optional)

## 📁 Struktur File

```
/home/debian/monitoring/
├── prometheus-2.48.0.linux-amd64/
│   ├── prometheus                    # Binary Prometheus
│   └── prometheus.yml                # Config file
├── node_exporter-1.7.0.linux-amd64/
│   └── node_exporter                 # Binary Node Exporter
├── api_examples/
│   ├── prometheus_api_example.py     # Contoh Python untuk Prometheus
│   ├── grafana_api_example.py        # Contoh Python untuk Grafana
│   └── curl_examples.sh              # Contoh curl commands
├── DOKUMENTASI.md                    # Dokumentasi lengkap
└── README.md                         # File ini
```

## ⚠️ Troubleshooting

### Layanan tidak bisa diakses?
```bash
# Cek status semua ports
sudo ss -tlnp | grep -E '9090|9100|3000'

# Restart layanan jika perlu
pkill -f prometheus && cd /home/debian/monitoring/prometheus-2.48.0.linux-amd64 && ./prometheus --config.file=prometheus.yml &
pkill -f node_exporter && cd /home/debian/monitoring/node_exporter-1.7.0.linux-amd64 && ./node_exporter &
sudo systemctl restart grafana-server
```

### Grafana tidak bisa connect ke Prometheus?
Pastikan URL data source di Grafana: `http://localhost:9090` (bukan IP address)

---

**Selamat menggunakan sistem monitoring! 🎉**

Untuk pertanyaan lebih lanjut, lihat dokumentasi lengkap atau cek referensi di:
- Prometheus: https://prometheus.io/docs/
- Grafana: https://grafana.com/docs/
