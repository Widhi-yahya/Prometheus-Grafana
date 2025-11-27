#!/usr/bin/env python3
"""
Contoh penggunaan Grafana API untuk mengakses data monitoring
"""

import requests
import json

# URL Grafana API
GRAFANA_URL = "http://localhost:3000"
# Default credentials Grafana
USERNAME = "admin"
PASSWORD = "admin"

def get_dashboards(auth):
    """
    Mengambil daftar semua dashboard
    """
    url = f"{GRAFANA_URL}/api/search"
    response = requests.get(url, auth=auth)
    
    if response.status_code == 200:
        return response.json()
    else:
        return None

def get_datasources(auth):
    """
    Mengambil daftar semua data sources
    """
    url = f"{GRAFANA_URL}/api/datasources"
    response = requests.get(url, auth=auth)
    
    if response.status_code == 200:
        return response.json()
    else:
        return None

def query_datasource(auth, datasource_id, query):
    """
    Menjalankan query pada data source
    """
    url = f"{GRAFANA_URL}/api/ds/query"
    headers = {'Content-Type': 'application/json'}
    
    payload = {
        "queries": [
            {
                "datasourceId": datasource_id,
                "expr": query,
                "refId": "A"
            }
        ]
    }
    
    response = requests.post(url, auth=auth, headers=headers, json=payload)
    
    if response.status_code == 200:
        return response.json()
    else:
        return None

def get_health(auth):
    """
    Mengecek health status Grafana
    """
    url = f"{GRAFANA_URL}/api/health"
    response = requests.get(url, auth=auth)
    
    if response.status_code == 200:
        return response.json()
    else:
        return None

def main():
    auth = (USERNAME, PASSWORD)
    
    print("=" * 60)
    print("Contoh Penggunaan Grafana API")
    print("=" * 60)
    
    # 1. Health Check
    print("\n1. Grafana Health Status:")
    health = get_health(auth)
    if health:
        print(f"   Status: {json.dumps(health, indent=2)}")
    else:
        print("   Error: Cannot connect to Grafana")
        print(f"   Please make sure Grafana is running at {GRAFANA_URL}")
        print(f"   Default credentials: {USERNAME}/{PASSWORD}")
        return
    
    # 2. List Data Sources
    print("\n2. Available Data Sources:")
    datasources = get_datasources(auth)
    if datasources:
        for ds in datasources:
            print(f"   ID: {ds['id']}")
            print(f"   Name: {ds['name']}")
            print(f"   Type: {ds['type']}")
            print(f"   URL: {ds['url']}")
            print()
    else:
        print("   No data sources found or authentication failed")
    
    # 3. List Dashboards
    print("\n3. Available Dashboards:")
    dashboards = get_dashboards(auth)
    if dashboards:
        if len(dashboards) > 0:
            for db in dashboards:
                print(f"   UID: {db.get('uid', 'N/A')}")
                print(f"   Title: {db.get('title', 'N/A')}")
                print(f"   Type: {db.get('type', 'N/A')}")
                print()
        else:
            print("   No dashboards found (This is normal for new installation)")
    else:
        print("   Error fetching dashboards")
    
    print("\n" + "=" * 60)
    print("Note: Untuk menggunakan API Grafana secara penuh,")
    print("      disarankan untuk membuat API Key di Grafana UI")
    print("=" * 60)

if __name__ == "__main__":
    main()
