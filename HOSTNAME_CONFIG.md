# Konfigurasi Hostname untuk Node Exporter

## ✅ Perubahan yang Dilakukan

Node Exporter sekarang menggunakan **hostname** sebagai identifier, bukan `localhost:9100`.

### Konfigurasi Prometheus (prometheus.yml)

```yaml
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
        labels:
          instance: "matthew-ganteng"
          hostname: "matthew-ganteng"
```

## 📊 Cara Menggunakan Hostname dalam Query

### Query dengan Filter Hostname

```promql
# CPU usage untuk hostname tertentu
100 - (avg by(hostname) (irate(node_cpu_seconds_total{hostname="matthew-ganteng",mode="idle"}[5m])) * 100)

# Memory usage untuk hostname tertentu
(node_memory_MemTotal_bytes{hostname="matthew-ganteng"} - node_memory_MemAvailable_bytes{hostname="matthew-ganteng"}) / node_memory_MemTotal_bytes{hostname="matthew-ganteng"} * 100

# Disk usage untuk hostname tertentu
(node_filesystem_size_bytes{hostname="matthew-ganteng"} - node_filesystem_avail_bytes{hostname="matthew-ganteng"}) / node_filesystem_size_bytes{hostname="matthew-ganteng"} * 100

# Semua metrics untuk hostname
up{hostname="matthew-ganteng"}
```

### Contoh API dengan Hostname

```bash
# Query metrics berdasarkan hostname
curl 'http://localhost:9090/api/v1/query?query=up{hostname="matthew-ganteng"}'

# Query CPU untuk hostname
curl 'http://localhost:9090/api/v1/query?query=100-(avg(irate(node_cpu_seconds_total{hostname="matthew-ganteng",mode="idle"}[5m]))*100)'
```

## 🐍 Python Example dengan Hostname

```python
import requests

PROMETHEUS_URL = "http://localhost:9090"

def get_metrics_by_hostname(hostname, metric_query):
    """
    Query metrics berdasarkan hostname
    """
    # Tambahkan filter hostname ke query
    query = metric_query.format(hostname=hostname)
    url = f"{PROMETHEUS_URL}/api/v1/query"
    params = {'query': query}
    
    response = requests.get(url, params=params)
    data = response.json()
    
    if data['status'] == 'success':
        return data['data']['result']
    return None

# Contoh penggunaan
hostname = "matthew-ganteng"

# CPU usage
cpu_query = '100 - (avg by(hostname) (irate(node_cpu_seconds_total{{hostname="{hostname}",mode="idle"}}[5m])) * 100)'
cpu_result = get_metrics_by_hostname(hostname, cpu_query)
print(f"CPU Usage: {cpu_result}")

# Memory usage
mem_query = '(node_memory_MemTotal_bytes{{hostname="{hostname}"}} - node_memory_MemAvailable_bytes{{hostname="{hostname}"}}) / node_memory_MemTotal_bytes{{hostname="{hostname}"}} * 100'
mem_result = get_metrics_by_hostname(hostname, mem_query)
print(f"Memory Usage: {mem_result}")

# Check if host is up
up_query = 'up{{hostname="{hostname}"}}'
up_result = get_metrics_by_hostname(hostname, up_query)
print(f"Host Status: {up_result}")
```

## 🔄 Menambah Server Lain

Jika ingin menambah server lain ke monitoring, edit `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      # Server 1
      - targets: ["localhost:9100"]
        labels:
          instance: "matthew-ganteng"
          hostname: "matthew-ganteng"
          datacenter: "dc1"
          
      # Server 2
      - targets: ["192.168.1.100:9100"]
        labels:
          instance: "server2"
          hostname: "server2"
          datacenter: "dc1"
          
      # Server 3
      - targets: ["192.168.1.101:9100"]
        labels:
          instance: "server3"
          hostname: "server3"
          datacenter: "dc2"
```

Kemudian restart Prometheus:
```bash
pkill -f prometheus
cd /home/debian/monitoring/prometheus-2.48.0.linux-amd64
./prometheus --config.file=prometheus.yml &
```

## 💡 Keuntungan Menggunakan Hostname

1. **Identifikasi Mudah**: Langsung tahu server mana yang sedang di-monitor
2. **Multiple Servers**: Mudah membedakan antar server
3. **Dashboard**: Lebih readable di Grafana dashboard
4. **Filtering**: Mudah filter metrics berdasarkan hostname
5. **Custom Labels**: Bisa tambah label lain seperti datacenter, environment, dll

## 📈 Grafana dengan Hostname

Di Grafana, sekarang bisa filter by hostname:

1. Buat panel baru
2. Di query, gunakan:
   ```promql
   rate(node_cpu_seconds_total{hostname="matthew-ganteng"}[5m])
   ```
3. Atau gunakan variable untuk dynamic hostname selection

## ✅ Verifikasi

Cek apakah hostname sudah teraplikasi:

```bash
curl -s 'http://localhost:9090/api/v1/query?query=up' | python3 -m json.tool
```

Output akan menunjukkan label `hostname` dan `instance` dengan nilai `matthew-ganteng`.

---

**Note**: Setelah perubahan konfigurasi, Prometheus akan otomatis menggunakan hostname untuk semua metrics dari node_exporter.
