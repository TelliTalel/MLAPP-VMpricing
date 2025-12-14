"""
Quick test script for the recommendation endpoint
"""
import requests
import json

API_URL = "http://192.168.100.9:8000"

# Test data
test_input = {
    "vcpus": 4,
    "memory_gb": 16,
    "boot_disk_gb": 200,
    "gpu_count": 0,
    "gpu_model": "none",
    "usage_hours_month": 730
}

print("=" * 80)
print("TESTING RECOMMENDATION ENDPOINT")
print("=" * 80)

print(f"\n📤 Sending request to: {API_URL}/recommend")
print(f"Input: {json.dumps(test_input, indent=2)}")

try:
    response = requests.post(
        f"{API_URL}/recommend",
        json=test_input,
        timeout=30
    )
    
    print(f"\n📡 Response Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n✅ SUCCESS!")
        print(f"Recommendations received: {len(data.get('recommendations', []))}")
        
        if data.get('recommendations'):
            print(f"\n📊 Query Summary:")
            print(f"  - Cluster: {data['query_summary']['cluster']}")
            print(f"  - Total similar VMs: {data['query_summary']['total_similar_vms']}")
            
            print(f"\n⭐ Top 5 Recommendations:")
            for i, rec in enumerate(data['recommendations'], 1):
                print(f"\n  #{i} - {rec['monthly_cost_formatted']}")
                print(f"      vCPUs: {rec['vcpus']}, RAM: {rec['memory_gb']} GB, Storage: {rec['storage_gb']} GB")
                print(f"      GPU Count: {rec['gpu_count']}")
                if 'machine_type' in rec:
                    print(f"      Machine Type: {rec['machine_type']}")
                if 'region' in rec:
                    print(f"      Region: {rec['region']}")
                print(f"      Category: {rec['category']}")
                print(f"      Value Score: {rec['value_score']:.4f}")
                print(f"      Similarity: {rec['similarity']:.2%}")
        else:
            print("\n⚠️ No recommendations returned")
            print(f"Message: {data.get('message', 'N/A')}")
    else:
        print(f"\n❌ ERROR: {response.status_code}")
        print(f"Response: {response.text}")
        
except requests.exceptions.ConnectionError:
    print(f"\n❌ CONNECTION ERROR: Cannot connect to {API_URL}")
    print("Make sure the FastAPI server is running!")
except Exception as e:
    print(f"\n❌ ERROR: {e}")

print("\n" + "=" * 80)

