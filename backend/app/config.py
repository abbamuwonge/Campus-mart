
"""Settings. Every value can be overridden with an environment variable."""
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-change-me-before-deploying")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))

_raw_database_url = os.getenv(
    "DATABASE_URL",
    f"sqlite:///{BASE_DIR / 'campusmart.db'}"
)

if _raw_database_url.startswith("postgres://"):
    DATABASE_URL = _raw_database_url.replace(
        "postgres://", "postgresql+psycopg://", 1
    )
elif _raw_database_url.startswith("postgresql://"):
    DATABASE_URL = _raw_database_url.replace(
        "postgresql://", "postgresql+psycopg://", 1
    )
else:
    DATABASE_URL = _raw_database_url

# Render will provide a persistent directory for uploaded images.
UPLOAD_DIR = Path(os.getenv("UPLOAD_DIR", str(BASE_DIR / "uploads")))
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

MAX_UPLOAD_BYTES = 5 * 1024 * 1024

PAGE_SIZE = 20

ADMIN_EMAIL = os.getenv("ADMIN_EMAIL", "admin@campusmart.ug")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "Admin12345")
