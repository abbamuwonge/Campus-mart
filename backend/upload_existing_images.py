
import os
from pathlib import Path
import httpx

SUPABASE_URL = os.environ["SUPABASE_URL"].rstrip("/")
SUPABASE_SECRET_KEY = os.environ["SUPABASE_SECRET_KEY"]
SUPABASE_ANON_KEY = os.environ["SUPABASE_ANON_KEY"]

BUCKET = "product-images"
IMAGE_DIR = Path(r"C:\Users\kamara\Desktop\CampusMart-Backup\uploads")

headers = {
    "apikey": SUPABASE_SECRET_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "image/jpeg",
    "x-upsert": "true",
}

filename = "eadc09a8b25345d38af0c50536cbc4c8.jpg"
file_path = IMAGE_DIR / filename

if not file_path.exists():
    print("Image file not found:", file_path)
else:
    url = f"{SUPABASE_URL}/storage/v1/object/{BUCKET}/{filename}"

    try:
        response = httpx.post(
            url,
            headers=headers,
            content=file_path.read_bytes(),
            timeout=60,
        )

        print("HTTP status:", response.status_code)
        print("Response:", response.text)

        if response.status_code in (200, 201):
            print("UPLOAD SUCCESSFUL")
            print(
                "Public URL:",
                f"{SUPABASE_URL}/storage/v1/object/public/{BUCKET}/{filename}"
            )

    except Exception as error:
        print("Connection error:", error)
