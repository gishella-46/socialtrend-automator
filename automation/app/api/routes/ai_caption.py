"""AI caption generation endpoint routes."""

from typing import List

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.services.ai_caption import AICaptionService
from app.services.auth_service import get_current_active_user
from app.utils.logging import logger

router = APIRouter(prefix="/api/ai", tags=["ai"])


class AICaptionRequest(BaseModel):
    """Request model for AI caption endpoint."""
    topic: str = Field(..., description="Main topic or subject")
    style: str = Field(
        default="professional",
        description="Caption style (professional, casual, creative)"
    )
    trend: List[str] = Field(
        default=[],
        description="List of trending keywords or topics"
    )


@router.post("/caption", summary="Generate AI caption and hashtags")
async def generate_ai_caption(
    request: AICaptionRequest,
    _current_user: dict = Depends(get_current_active_user)
):
    """
    Generate social media caption and hashtags using AI.

    Uses OpenAI GPT-4 if OPENAI_API_KEY is set, otherwise uses fallback method.
    """
    try:
        logger.info(
            "AI caption generation request",
            extra={
                "topic": request.topic,
                "style": request.style,
                "trend_count": len(request.trend),
            }
        )

        result = await AICaptionService.generate_caption(
            topic=request.topic,
            trend=request.trend,
            style=request.style
        )

        # Return direct format: { caption, hashtags, recommended_time }
        return {
            "caption": result.get("caption"),
            "hashtags": result.get("hashtags"),
            "recommended_time": result.get("recommended_time")
        }

    except Exception as e:
        logger.error("AI caption generation error", extra={"error": str(e)}, exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error") from e
