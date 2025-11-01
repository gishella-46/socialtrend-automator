"""Celery metrics exporter for Prometheus."""

from prometheus_client import Counter, Histogram, Gauge
from celery import current_app
from app.utils.logging import logger

# Celery task metrics
task_duration = Histogram(
    'celery_task_duration_seconds',
    'Duration of Celery tasks in seconds',
    ['task_name', 'status'],
    buckets=[0.1, 0.5, 1.0, 2.5, 5.0, 10.0, 30.0, 60.0]
)

task_count = Counter(
    'celery_tasks_total',
    'Total number of Celery tasks',
    ['task_name', 'status']
)

queue_length = Gauge(
    'celery_queue_length',
    'Number of tasks in queue',
    ['queue_name']
)


def update_queue_metrics():
    """Update queue length metrics."""
    try:
        inspect = current_app.control.inspect()
        active_queues = inspect.active_queues()

        if active_queues:
            for queues in active_queues.values():
                for queue in queues:
                    queue_name = queue.get('name', 'default')
                    # Get queue length from Redis
                    # This is a simplified version - you'd need Redis connection
                    queue_length.labels(queue_name=queue_name).set(0)
    except (ConnectionError, AttributeError, RuntimeError) as e:
        logger.error("Failed to update queue metrics: %s", str(e))


def record_task_duration(task_name: str, duration: float, status: str = 'success'):
    """Record task duration metric."""
    task_duration.labels(task_name=task_name, status=status).observe(duration)
    task_count.labels(task_name=task_name, status=status).inc()
