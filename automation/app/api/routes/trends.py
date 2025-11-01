"""Trends endpoint routes."""

from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.services.trends_service import TrendsService
from app.services.auth_service import get_current_active_user
from app.utils.logging import logger

router = APIRouter(prefix="/api/trends", tags=["trends"])


class FetchTrendsRequest(BaseModel):
    """Request model for fetch trends endpoint."""
    platform: str = Field(
        ...,
        description="Platform to fetch from (google, reddit, twitter)"
    )
    keywords: Optional[List[str]] = Field(default=[], description="Keywords to search")
    timeframe: Optional[str] = Field(
        default="today 12-m",
        description="Timeframe for Google Trends"
    )


@router.post("/fetch", summary="Fetch trends from social media platforms")
async def fetch_trends(
    request: FetchTrendsRequest,
    _current_user: dict = Depends(get_current_active_user)
):
    """
    Fetch trending topics from Google Trends, Reddit, or Twitter.

    - Google: Uses pytrends
    - Reddit: Uses PRAW (Reddit API)
    - Twitter: Uses Tweepy (Twitter API)
    """
    try:
        logger.info(
            "Trends fetch request",
            extra={
                "platform": request.platform,
                "keywords": request.keywords,
            }
        )

        result = await TrendsService.fetch_trends(
            platform=request.platform,
            keywords=request.keywords or [],
            timeframe=request.timeframe or "today 12-m"
        )

        return {
            "success": True,
            "data": result
        }

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except Exception as e:
        logger.error("Trends fetch error", extra={"error": str(e)}, exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error") from e
