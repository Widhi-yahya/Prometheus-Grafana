#!/bin/bash
# Contoh penggunaan API monitoring menggunakan curl

echo "======================================================================"
echo "Contoh Penggunaan Prometheus & Grafana API dengan curl"
echo "======================================================================"

# Prometheus API Examples
echo -e "\n1. Prometheus - Mengecek status targets:"
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, instance: .labels.instance, health: .health}'

echo -e "\n2. Prometheus - Query CPU usage:"
curl -s "http://localhost:9090/api/v1/query?query=100-(avg%20by(instance)%20(irate(node_cpu_seconds_total{mode=\"idle\"}[5m]))*100)" | jq '.data.result[]'

echo -e "\n3. Prometheus - Query Memory usage:"
curl -s "http://localhost:9090/api/v1/query?query=(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)/node_memory_MemTotal_bytes*100" | jq '.data.result[]'

echo -e "\n4. Prometheus - Query Disk usage:"
curl -s "http://localhost:9090/api/v1/query?query=(node_filesystem_size_bytes{fstype!=\"tmpfs\"}-node_filesystem_avail_bytes{fstype!=\"tmpfs\"})/node_filesystem_size_bytes{fstype!=\"tmpfs\"}*100" | jq '.data.result[] | {mountpoint: .metric.mountpoint, usage: .value[1]}'

echo -e "\n5. Prometheus - Daftar semua metrics:"
curl -s http://localhost:9090/api/v1/label/__name__/values | jq '.data[:10]'

echo -e "\n6. Prometheus - Range query (CPU 1 jam terakhir):"
END_TIME=$(date +%s)
START_TIME=$((END_TIME - 3600))
curl -s "http://localhost:9090/api/v1/query_range?query=100-(avg%20by(instance)%20(irate(node_cpu_seconds_total{mode=\"idle\"}[5m]))*100)&start=${START_TIME}&end=${END_TIME}&step=5m" | jq '.data.result[0].values[:5]'

# Grafana API Examples
echo -e "\n======================================================================"
echo "Grafana API Examples (memerlukan authentication)"
echo "======================================================================"

echo -e "\n7. Grafana - Health check:"
curl -s http://localhost:3000/api/health | jq '.'

echo -e "\n8. Grafana - List data sources (dengan basic auth):"
curl -s -u admin:admin http://localhost:3000/api/datasources | jq '.[] | {id: .id, name: .name, type: .type}'

echo -e "\n9. Grafana - List dashboards (dengan basic auth):"
curl -s -u admin:admin http://localhost:3000/api/search | jq '.[] | {uid: .uid, title: .title, type: .type}'

echo -e "\n10. Grafana - Get org info (dengan basic auth):"
curl -s -u admin:admin http://localhost:3000/api/org | jq '.'

echo -e "\n======================================================================"
echo "Catatan:"
echo "- Ganti 'admin:admin' dengan credentials Grafana Anda"
echo "- Untuk production, gunakan API Key bukan basic auth"
echo "- Install 'jq' untuk format JSON yang lebih baik: sudo apt-get install jq"
echo "======================================================================"
