"""Caption generation endpoint routes."""

from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.services.caption_service import CaptionService
from app.services.auth_service import get_current_active_user
from app.utils.logging import logger

router = APIRouter(prefix="/api", tags=["caption"])


class GenerateCaptionRequest(BaseModel):
    """Request model for generate caption endpoint."""
    content: Optional[str] = Field(None, description="Base content or topic")
    image_description: Optional[str] = Field(None, description="Description of image/media")
    platform: str = Field(default="instagram", description="Target platform")
    style: str = Field(
        default="professional",
        description="Caption style (professional, casual, creative)"
    )


@router.post("/generate_caption", summary="Generate caption and hashtags using AI")
async def generate_caption(
    request: GenerateCaptionRequest,
    _current_user: dict = Depends(get_current_active_user)
):
    """
    Generate social media caption and hashtags using AI.

    Uses OpenAI API if OPENAI_API_KEY is set, otherwise uses HuggingFace models.
    """
    try:
        logger.info(
            "Caption generation request",
            extra={
                "platform": request.platform,
                "style": request.style,
            }
        )

        result = await CaptionService.generate_caption(
            content=request.content,
            image_description=request.image_description,
            platform=request.platform,
            style=request.style
        )

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error("Caption generation error", extra={"error": str(e)}, exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error") from e
