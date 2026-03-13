import json
import base64
import os

def generate_dokploy_payload(compose_path='docker-compose.yml', template_path='template.toml'):
    """
    Creates a Dokploy-compatible Base64 payload.
    The structure is a JSON object: {"compose": "...", "config": "..."}
    where the values are the raw strings from the files.
    """
    if not os.path.exists(compose_path) or not os.path.exists(template_path):
        return "Error: Required files (docker-compose.yml or template.toml) are missing."

    with open(compose_path, 'r') as f:
        compose_text = f.read()

    with open(template_path, 'r') as f:
        template_text = f.read()

    # Construct the dictionary
    payload_dict = {
        "compose": compose_text,
        "config": template_text
    }

    # Convert to JSON with specific separators to match common JS output if needed
    # but standard json.dumps is usually exactly what's expected.
    json_payload = json.dumps(payload_dict)

    # Encode to Base64
    encoded = base64.b64encode(json_payload.encode('utf-8')).decode('utf-8')
    
    return encoded

if __name__ == "__main__":
    result = generate_dokploy_payload()
    print(result)
