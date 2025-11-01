"""Upload endpoint routes."""

from typing import List, Optional

import httpx
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException
from pydantic import BaseModel, Field

from app.services.upload_service import UploadService
from app.services.auth_service import get_current_active_user
from app.utils.logging import logger

router = APIRouter(prefix="/api", tags=["upload"])


class UploadRequest(BaseModel):
    """Request model for upload endpoint."""
    platform: str = Field(..., description="Target platform (instagram, linkedin)")
    content: str = Field(..., description="Text content to upload")
    media_urls: Optional[List[str]] = Field(
        default=[],
        description="Media URLs to attach"
    )
    scheduled_post_id: Optional[int] = Field(
        None,
        description="ID from backend scheduled post"
    )
    callback_url: Optional[str] = Field(
        None,
        description="Callback URL for status update"
    )


@router.post("/upload", summary="Upload content to social media platform")
async def upload_content(
    request: UploadRequest,
    background_tasks: BackgroundTasks,
    _current_user: dict = Depends(get_current_active_user)
):
    """
    Upload content manually to Instagram or LinkedIn.

    If callback_url is provided, will send callback when upload is complete.
    """
    try:
        logger.info(
            "Upload request received",
            extra={
                "platform": request.platform,
                "scheduled_post_id": request.scheduled_post_id,
            }
        )

        # Perform upload
        result = await UploadService.upload_to_platform(
            platform=request.platform,
            content=request.content,
            media_urls=request.media_urls or [],
            scheduled_post_id=request.scheduled_post_id,
            callback_url=request.callback_url,
        )

        # Send callback if provided
        if request.callback_url:
            background_tasks.add_task(
                _send_callback,
                request.callback_url,
                request.scheduled_post_id,
                result
            )

        return {
            "success": True,
            "message": "Upload initiated successfully",
            "data": result
        }

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except Exception as e:
        logger.error("Upload endpoint error", extra={"error": str(e)}, exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error") from e


async def _send_callback(callback_url: str, scheduled_post_id: int, result: dict):
    """Send callback to backend webhook."""
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            await client.post(
                callback_url,
                json={
                    "scheduled_post_id": scheduled_post_id,
                    "status": result.get("status", "posted"),
                    "message": result.get("message"),
                    "post_url": result.get("post_url"),
                }
            )
            logger.info("Callback sent", extra={"callback_url": callback_url})
    except Exception as e:  # pylint: disable=broad-except
        logger.error("Failed to send callback", extra={"error": str(e)}, exc_info=True)
