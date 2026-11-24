
from sqlalchemy.engine import make_url

from app.config import DATABASE_URL
from app.database import SessionLocal
from app.models import Item

# Safety check: never run this update against local SQLite.
url = make_url(DATABASE_URL)
if not url.drivername.startswith("postgresql"):
    raise RuntimeError("STOP: This is not the production PostgreSQL database.")

BASE_URL = (
    "https://aqhicabmjktsarkgmvgr.supabase.co"
    "/storage/v1/object/public/product-images/"
)

updates = {
    1: ("laptop Acer", "eadc09a8b25345d38af0c50536cbc4c8.jpg"),
    2: ("galaxy A04s", "67087acb589f436c8f73269132e2dbad.jpg"),
    3: ("sumsung S10 plus", "e45332b80312422ab7476beee6dd15fe.jpg"),
    4: ("hp elitebook", "c7c47be624d5438996d015dc7f631d69.jpg"),
    6: ("creeping tool", "d902f196be6a41929902eabde86da1f3.jpg"),
}

db = SessionLocal()

try:
    for item_id, (expected_title, filename) in updates.items():
        item = db.get(Item, item_id)

        if item is None:
            raise RuntimeError(f"Product ID {item_id} does not exist.")

        if item.title != expected_title:
            raise RuntimeError(
                f"Product {item_id} title mismatch: {item.title}"
            )

        expected_old_path = f"/uploads/{filename}"

        if item.image_url != expected_old_path:
            raise RuntimeError(
                f"Product {item_id} image path changed unexpectedly: "
                f"{item.image_url}"
            )

        item.image_url = BASE_URL + filename

    db.commit()
    print("SUCCESS: Five product image URLs updated.")

    for item_id in updates:
        item = db.get(Item, item_id)
        print(item.item_id, "|", item.title, "|", item.image_url)

except Exception:
    db.rollback()
    raise

finally:
    db.close()
