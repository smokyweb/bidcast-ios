import jwt
import time
import requests
import os
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa


def api(method, path, body=None):
    iss = os.environ["APP_STORE_CONNECT_ISSUER_ID"]
    kid = os.environ["APP_STORE_CONNECT_KEY_IDENTIFIER"]
    key = os.environ["APP_STORE_CONNECT_PRIVATE_KEY"]
    token = jwt.encode(
        {"iss": iss, "exp": int(time.time()) + 300, "aud": "appstoreconnect-v1"},
        key, algorithm="ES256", headers={"kid": kid}
    )
    headers = {"Authorization": f"Bearer {token}"}
    url = f"https://api.appstoreconnect.apple.com/v1/{path}"
    r = getattr(requests, method.lower())(url, headers=headers, json=body)
    if r.status_code not in (200, 201, 204):
        raise Exception(f"{method} {path}: {r.status_code} {r.text}")
    return r.json() if r.content else {}


# Delete existing iOS Distribution certs to avoid private key conflicts
try:
    # Delete ALL Distribution type certs (both IOS_DISTRIBUTION and DISTRIBUTION) to avoid 409s
    dist_certs = []
    for t in ("IOS_DISTRIBUTION", "DISTRIBUTION"):
        resp = api("GET", f"certificates?filter[certificateType]={t}&limit=200")
        dist_certs.extend(resp.get("data", []))
    certs = {"data": dist_certs}
    for c in certs.get("data", []):
        cid = c["id"]
        print(f"Deleting cert {cid}")
        api("DELETE", f"certificates/{cid}")
    print("Old certs cleaned up.")
except Exception as e:
    print(f"Warning during cert cleanup: {e}")

# Generate fresh RSA key and save to /tmp/dist_signing.key
private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048,
    backend=default_backend()
)
pem = private_key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.TraditionalOpenSSL,
    encryption_algorithm=serialization.NoEncryption()
).decode()

with open("/tmp/dist_signing.key", "w") as f:
    f.write(pem)

print("RSA key written to /tmp/dist_signing.key")
