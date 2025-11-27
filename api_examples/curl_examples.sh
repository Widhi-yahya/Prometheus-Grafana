#!/bin/bash
# Contoh penggunaan API monitoring menggunakan curl

echo "======================================================================"
echo "Contoh Penggunaan Prometheus & Grafana API dengan curl"
echo "======================================================================"

# Check if jq is available
if command -v jq &> /dev/null; then
    HAS_JQ=true
    echo "Using jq for formatted JSON output"
else
    HAS_JQ=false
    echo "Note: Install 'jq' for better formatted output: sudo apt-get install jq"
fi

# Prometheus API Examples
echo -e "\n1. Prometheus - Mengecek status targets:"
if [ "$HAS_JQ" = true ]; then
    curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, instance: .labels.instance, health: .health}'
else
    curl -s http://localhost:9090/api/v1/targets | python3 -m json.tool
fi

echo -e "\n2. Prometheus - Query CPU usage:"
if [ "$HAS_JQ" = true ]; then
    curl -s 'http://localhost:9090/api/v1/query' --data-urlencode 'query=100-(avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m]))*100)' | jq '.data.result[]'
else
    curl -s 'http://localhost:9090/api/v1/query' --data-urlencode 'query=100-(avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m]))*100)' | python3 -m json.tool
fi

echo -e "\n3. Prometheus - Query Memory usage:"
if [ "$HAS_JQ" = true ]; then
    curl -s 'http://localhost:9090/api/v1/query' --data-urlencode 'query=(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)/node_memory_MemTotal_bytes*100' | jq '.data.result[]'
else
    curl -s 'http://localhost:9090/api/v1/query' --data-urlencode 'query=(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)/node_memory_MemTotal_bytes*100' | python3 -m json.tool
fi

echo -e "\n4. Prometheus - Query Disk usage:"
if [ "$HAS_JQ" = true ]; then
    curl -s 'http://localhost:9090/api/v1/query' --data-urlencode 'query=(node_filesystem_size_bytes{fstype!="tmpfs",mountpoint="/"}-node_filesystem_avail_bytes{fstype!="tmpfs",mountpoint="/"})/node_filesystem_size_bytes{fstype!="tmpfs",mountpoint="/"}*100' | jq '.data.result[] | {mountpoint: .metric.mountpoint, usage: .value[1]}'
else
    curl -s 'http://localhost:9090/api/v1/query' --data-urlencode 'query=(node_filesystem_size_bytes{fstype!="tmpfs",mountpoint="/"}-node_filesystem_avail_bytes{fstype!="tmpfs",mountpoint="/"})/node_filesystem_size_bytes{fstype!="tmpfs",mountpoint="/"}*100' | python3 -m json.tool | head -40
fi

echo -e "\n5. Prometheus - Daftar semua metrics:"
if [ "$HAS_JQ" = true ]; then
    curl -s http://localhost:9090/api/v1/label/__name__/values | jq '.data[:10]'
else
    curl -s http://localhost:9090/api/v1/label/__name__/values | python3 -m json.tool | head -30
fi

echo -e "\n6. Prometheus - Range query (CPU 1 jam terakhir):"
END_TIME=$(date +%s)
START_TIME=$((END_TIME - 3600))
if [ "$HAS_JQ" = true ]; then
    curl -s 'http://localhost:9090/api/v1/query_range' \
        --data-urlencode 'query=100-(avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m]))*100)' \
        --data-urlencode "start=${START_TIME}" \
        --data-urlencode "end=${END_TIME}" \
        --data-urlencode 'step=5m' | jq '.data.result[0].values[:5]'
else
    curl -s 'http://localhost:9090/api/v1/query_range' \
        --data-urlencode 'query=100-(avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m]))*100)' \
        --data-urlencode "start=${START_TIME}" \
        --data-urlencode "end=${END_TIME}" \
        --data-urlencode 'step=5m' | python3 -m json.tool | head -40
fi

# Grafana API Examples
echo -e "\n======================================================================"
echo "Grafana API Examples (memerlukan authentication)"
echo "======================================================================"

echo -e "\n7. Grafana - Health check:"
if [ "$HAS_JQ" = true ]; then
    curl -s http://localhost:3000/api/health | jq '.'
else
    curl -s http://localhost:3000/api/health | python3 -m json.tool
fi

echo -e "\n8. Grafana - List data sources (dengan basic auth):"
if [ "$HAS_JQ" = true ]; then
    curl -s -u admin:admin http://localhost:3000/api/datasources | jq '.[] | {id: .id, name: .name, type: .type}'
else
    curl -s -u admin:admin http://localhost:3000/api/datasources | python3 -m json.tool
fi

echo -e "\n9. Grafana - List dashboards (dengan basic auth):"
if [ "$HAS_JQ" = true ]; then
    curl -s -u admin:admin http://localhost:3000/api/search | jq '.[] | {uid: .uid, title: .title, type: .type}'
else
    curl -s -u admin:admin http://localhost:3000/api/search | python3 -m json.tool
fi

echo -e "\n10. Grafana - Get org info (dengan basic auth):"
if [ "$HAS_JQ" = true ]; then
    curl -s -u admin:admin http://localhost:3000/api/org | jq '.'
else
    curl -s -u admin:admin http://localhost:3000/api/org | python3 -m json.tool
fi

echo -e "\n======================================================================"
echo "Catatan:"
echo "- Ganti 'admin:admin' dengan credentials Grafana Anda"
echo "- Untuk production, gunakan API Key bukan basic auth"
echo "- Install 'jq' untuk format JSON yang lebih baik: sudo apt-get install jq"
echo "======================================================================"
