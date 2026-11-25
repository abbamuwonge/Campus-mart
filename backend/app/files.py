
"""Upload and delete CampusMart product images using Supabase S3 Storage."""

import uuid
from pathlib import Path
from typing import Optional
from urllib.parse import urlparse

import boto3
from botocore.config import Config
from botocore.exceptions import BotoCoreError, ClientError
from fastapi import HTTPException

from .config import (
    MAX_UPLOAD_BYTES,
    SUPABASE_URL,
    SUPABASE_BUCKET,
    SUPABASE_S3_ENDPOINT,
    SUPABASE_S3_REGION,
    SUPABASE_S3_ACCESS_KEY_ID,
    SUPABASE_S3_SECRET_ACCESS_KEY,
    UPLOAD_DIR,
)


def _sniff_extension(data: bytes) -> Optional[str]:
    """Identify image type using its actual file signature."""
    if data.startswith(b"\xff\xd8\xff"):
        return ".jpg"
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return ".png"
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return ".webp"
    return None


def _storage_client():
    """Create an authenticated Supabase S3 client."""
    required = {
        "SUPABASE_URL": SUPABASE_URL,
        "SUPABASE_S3_ENDPOINT": SUPABASE_S3_ENDPOINT,
        "SUPABASE_S3_REGION": SUPABASE_S3_REGION,
        "SUPABASE_S3_ACCESS_KEY_ID": SUPABASE_S3_ACCESS_KEY_ID,
        "SUPABASE_S3_SECRET_ACCESS_KEY": SUPABASE_S3_SECRET_ACCESS_KEY,
    }

    if any(not value for value in required.values()):
        raise HTTPException(
            status_code=503,
            detail="Image storage is not configured",
        )

    return boto3.client(
        "s3",
        endpoint_url=SUPABASE_S3_ENDPOINT,
        region_name=SUPABASE_S3_REGION,
        aws_access_key_id=SUPABASE_S3_ACCESS_KEY_ID,
        aws_secret_access_key=SUPABASE_S3_SECRET_ACCESS_KEY,
        config=Config(
            signature_version="s3v4",
            s3={"addressing_style": "path"},
        ),
    )


def save_image(data: bytes) -> str:
    """Validate and upload an image to Supabase Storage."""

    if not data:
        raise HTTPException(status_code=400, detail="The file is empty")

    if len(data) > MAX_UPLOAD_BYTES:
        raise HTTPException(
            status_code=400,
            detail="Photo is larger than 5 MB",
        )

    extension = _sniff_extension(data)

    if extension is None:
        raise HTTPException(
            status_code=400,
            detail="Only JPG, PNG or WEBP photos are allowed",
        )

    content_types = {
        ".jpg": "image/jpeg",
        ".png": "image/png",
        ".webp": "image/webp",
    }

    name = f"{uuid.uuid4().hex}{extension}"

    try:
        client = _storage_client()
        client.put_object(
            Bucket=SUPABASE_BUCKET,
            Key=name,
            Body=data,
            ContentType=content_types[extension],
            CacheControl="public, max-age=31536000",
        )
    except HTTPException:
        raise
    except (BotoCoreError, ClientError):
        raise HTTPException(
            status_code=502,
            detail="Could not upload image to storage",
        )

    return (
        f"{SUPABASE_URL}/storage/v1/object/public/"
        f"{SUPABASE_BUCKET}/{name}"
    )


def delete_upload(image_url: Optional[str]) -> None:
    """Delete an image from Supabase or the old local uploads folder."""

    if not image_url:
        return

    # Support deletion of old locally stored images.
    if image_url.startswith("/uploads/"):
        try:
            (UPLOAD_DIR / Path(image_url).name).unlink(missing_ok=True)
        except OSError:
            pass
        return

    if not SUPABASE_URL:
        return

    parsed = urlparse(image_url)
    expected_host = urlparse(SUPABASE_URL).netloc
    expected_prefix = (
        f"/storage/v1/object/public/{SUPABASE_BUCKET}/"
    )

    if parsed.netloc != expected_host:
        return

    if not parsed.path.startswith(expected_prefix):
        return

    image_name = parsed.path[len(expected_prefix):]

    if not image_name or "/" in image_name:
        return

    try:
        client = _storage_client()
        client.delete_object(
            Bucket=SUPABASE_BUCKET,
            Key=image_name,
        )
    except (HTTPException, BotoCoreError, ClientError):
        # Do not break product updates if image deletion fails.
        pass
