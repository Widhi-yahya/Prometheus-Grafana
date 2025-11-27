#!/usr/bin/env python3
"""
Contoh penggunaan Prometheus API untuk mengakses data monitoring
"""

import requests
import json
from datetime import datetime

# URL Prometheus API
PROMETHEUS_URL = "http://localhost:9090"

def get_current_metrics(query):
    """
    Mengambil metrics saat ini (instant query)
    """
    url = f"{PROMETHEUS_URL}/api/v1/query"
    params = {'query': query}
    
    response = requests.get(url, params=params)
    data = response.json()
    
    if data['status'] == 'success':
        return data['data']['result']
    else:
        return None

def get_metrics_range(query, start, end, step='15s'):
    """
    Mengambil metrics dalam rentang waktu (range query)
    """
    url = f"{PROMETHEUS_URL}/api/v1/query_range"
    params = {
        'query': query,
        'start': start,
        'end': end,
        'step': step
    }
    
    response = requests.get(url, params=params)
    data = response.json()
    
    if data['status'] == 'success':
        return data['data']['result']
    else:
        return None

def get_targets():
    """
    Mengambil daftar target yang sedang di-scrape
    """
    url = f"{PROMETHEUS_URL}/api/v1/targets"
    response = requests.get(url)
    data = response.json()
    
    if data['status'] == 'success':
        return data['data']['activeTargets']
    else:
        return None

def main():
    print("=" * 60)
    print("Contoh Penggunaan Prometheus API")
    print("=" * 60)
    
    # 1. Mengambil penggunaan CPU
    print("\n1. CPU Usage:")
    cpu_query = '100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'
    cpu_data = get_current_metrics(cpu_query)
    if cpu_data:
        for item in cpu_data:
            print(f"   Instance: {item['metric'].get('instance', 'N/A')}")
            print(f"   CPU Usage: {float(item['value'][1]):.2f}%")
    
    # 2. Mengambil penggunaan Memory
    print("\n2. Memory Usage:")
    memory_query = '(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100'
    memory_data = get_current_metrics(memory_query)
    if memory_data:
        for item in memory_data:
            print(f"   Instance: {item['metric'].get('instance', 'N/A')}")
            print(f"   Memory Usage: {float(item['value'][1]):.2f}%")
    
    # 3. Mengambil penggunaan Disk
    print("\n3. Disk Usage:")
    disk_query = '(node_filesystem_size_bytes{fstype!="tmpfs"} - node_filesystem_avail_bytes{fstype!="tmpfs"}) / node_filesystem_size_bytes{fstype!="tmpfs"} * 100'
    disk_data = get_current_metrics(disk_query)
    if disk_data:
        for item in disk_data[:3]:  # Tampilkan 3 teratas saja
            print(f"   Mountpoint: {item['metric'].get('mountpoint', 'N/A')}")
            print(f"   Disk Usage: {float(item['value'][1]):.2f}%")
    
    # 4. Mengambil daftar targets
    print("\n4. Active Targets:")
    targets = get_targets()
    if targets:
        for target in targets:
            print(f"   Job: {target['labels']['job']}")
            print(f"   Instance: {target['labels']['instance']}")
            print(f"   Health: {target['health']}")
            print(f"   Last Scrape: {target['lastScrape']}")
            print()
    
    # 5. Contoh range query untuk CPU dalam 1 jam terakhir
    print("\n5. CPU Usage (Last Hour - Range Query):")
    import time
    end_time = int(time.time())
    start_time = end_time - 3600  # 1 jam yang lalu
    
    cpu_range = get_metrics_range(cpu_query, start_time, end_time, '5m')
    if cpu_range:
        print(f"   Data points available: {len(cpu_range[0]['values']) if cpu_range else 0}")
        print(f"   First value: {cpu_range[0]['values'][0] if cpu_range and cpu_range[0]['values'] else 'N/A'}")
    
    print("\n" + "=" * 60)

if __name__ == "__main__":
    main()
