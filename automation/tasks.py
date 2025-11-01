"""Celery tasks for SocialTrend Automator background processing."""

import asyncio
import logging
import os
import time
from typing import Any, Dict

import httpx  # noqa: F401
from celery import Celery
from celery.signals import task_postrun, worker_ready
from dotenv import load_dotenv

from app.services.celery_metrics import record_task_duration, update_queue_metrics

# Load environment variables
load_dotenv()

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Celery
celery_app = Celery(
    'socialtrend_tasks',
    broker=os.getenv('REDIS_URL', 'redis://redis:6379/0'),
    backend=os.getenv('REDIS_URL', 'redis://redis:6379/0')
)

celery_app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
    task_routes={
        'tasks.auto_upload': {'queue': 'uploads'},
    },
)


@worker_ready.connect
def update_metrics_on_ready(**kwargs):  # pylint: disable=unused-argument
    """Update queue metrics when worker is ready."""
    try:
        update_queue_metrics()
    except Exception:  # pylint: disable=broad-except
        pass  # Metrics update is non-critical


@task_postrun.connect
def update_metrics_after_task(**kwargs):  # pylint: disable=unused-argument
    """Update queue metrics after task execution."""
    try:
        update_queue_metrics()
    except Exception:  # pylint: disable=broad-except
        pass  # Metrics update is non-critical


@celery_app.task(name='tasks.auto_upload', bind=True, max_retries=3)
def auto_upload(
    self, scheduled_post_id: int, platform: str, content: str,
    media_urls: list = None, callback_url: str = None
):
    """
    Background task for auto-uploading content to social media platforms.

    This task is called from Laravel backend when a scheduled post is ready.

    Args:
        scheduled_post_id: ID of scheduled post from backend
        platform: Target social media platform (instagram, linkedin, etc.)
        content: Text content to upload
        media_urls: List of media URLs to attach
        callback_url: URL to send callback when done

    Returns:
        dict: Status and details of the upload operation
    """
    task_start = time.time()
    task_name = 'tasks.auto_upload'

    logger.info(
        "Processing auto-upload for scheduled post %s to %s",
        scheduled_post_id,
        platform,
        extra={
            "scheduled_post_id": scheduled_post_id,
            "platform": platform,
            "task_id": self.request.id,
        }
    )

    try:
        # Import here to avoid circular imports
        from app.services.upload_service import UploadService  # pylint: disable=import-outside-toplevel  # type: ignore

        # Create event loop for async function
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)

        try:
            # Call async upload service
            result = loop.run_until_complete(
                UploadService.upload_to_platform(
                    platform=platform,
                    content=content,
                    media_urls=media_urls or [],
                    scheduled_post_id=scheduled_post_id,
                    callback_url=callback_url,
                )
            )
        finally:
            loop.close()

        task_duration = time.time() - task_start
        record_task_duration(task_name, task_duration, 'success')

        logger.info(  # noqa: G001
            "Auto-upload completed for scheduled post %s",
            scheduled_post_id,
            extra={
                "scheduled_post_id": scheduled_post_id,
                "platform": platform,
                "status": result.get("status"),
            }
        )

        return result

    except Exception as e:
        task_duration = time.time() - task_start
        record_task_duration(task_name, task_duration, 'failed')
        logger.error(  # noqa: G001
            "Auto-upload failed for scheduled post %s",
            scheduled_post_id,
            extra={
                "scheduled_post_id": scheduled_post_id,
                "platform": platform,
                "error": str(e),
            },
            exc_info=True
        )

        # Retry if needed
        if self.request.retries < self.max_retries:
            raise self.retry(exc=e, countdown=60 * (self.request.retries + 1))

        # Send failure callback
        if callback_url:
            try:
                httpx.post(
                    callback_url,
                    json={
                        "scheduled_post_id": scheduled_post_id,
                        "status": "failed",
                        "error": str(e),
                    },
                    timeout=10.0
                )
            except Exception as callback_error:  # pylint: disable=broad-except
                logger.error(
                    "Failed to send failure callback",
                    extra={"error": str(callback_error)}
                )

        raise


@celery_app.task(name='tasks.ai_process')
def ai_process(content_data: Dict[str, Any]):
    """
    Background task for AI content processing.

    Args:
        content_data: The content data to be processed by AI

    Returns:
        dict: Status and result of the AI processing
    """
    task_start = time.time()
    task_name = 'tasks.ai_process'

    logger.info("Processing AI content", extra={"content_data": content_data})

    try:
        # TODO: Implement AI processing  # pylint: disable=fixme
        # This can integrate with OpenAI, HuggingFace, etc.
        result = {
            "status": "success",
            "processed": True,
            "result": "AI processing completed"
        }
        task_duration = time.time() - task_start
        record_task_duration(task_name, task_duration, 'success')
        return result
    except Exception as e:
        task_duration = time.time() - task_start
        record_task_duration(task_name, task_duration, 'failed')
        logger.error("AI processing failed", extra={"error": str(e)}, exc_info=True)
        raise
