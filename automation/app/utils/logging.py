"""JSON logging configuration compatible with ELK stack."""

import logging
import os
import socket
import sys
from datetime import datetime

from pythonjsonlogger import jsonlogger  # pylint: disable=import-error


class CustomJsonFormatter(jsonlogger.JsonFormatter):
    """Custom JSON formatter for structured logging."""

    def add_fields(self, log_record, record, message_dict):
        """Add custom fields to log record."""
        super().add_fields(log_record, record, message_dict)

        # Standard fields
        log_record['timestamp'] = datetime.utcnow().isoformat() + 'Z'
        log_record['level'] = record.levelname
        log_record['logger'] = record.name
        log_record['module'] = record.module
        log_record['function'] = record.funcName
        log_record['line'] = record.lineno

        # Service identification
        log_record['service'] = 'socialtrend-automation'

        # Add exception info if present
        if record.exc_info:
            log_record['exception'] = self.formatException(record.exc_info)


class LogstashTcpHandler(logging.handlers.SocketHandler):
    """TCP handler for sending logs to Logstash."""

    def __init__(self, host='logstash', port=5000):
        """Initialize Logstash TCP handler."""
        super().__init__(host, port)

    def makePickle(self, record):
        """Format record as JSON string."""
        formatter = CustomJsonFormatter()
        formatted = formatter.format(record)
        return formatted.encode('utf-8') + b'\n'


def setup_logging(log_level: str = "INFO"):
    """
    Setup JSON logging compatible with ELK stack.

    Args:
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
    """
    handlers = []

    # Console handler (stdout)
    console_handler = logging.StreamHandler(sys.stdout)
    formatter = CustomJsonFormatter(
        '%(timestamp)s %(level)s %(name)s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S'
    )
    console_handler.setFormatter(formatter)
    handlers.append(console_handler)

    # Logstash TCP handler (if LOGSTASH_ENABLED=true)
    logstash_enabled = os.getenv('LOGSTASH_ENABLED', 'true').lower() == 'true'
    if logstash_enabled:
        try:
            logstash_host = os.getenv('LOGSTASH_HOST', 'logstash')
            logstash_port = int(os.getenv('LOGSTASH_PORT', '5000'))
            logstash_handler = LogstashTcpHandler(logstash_host, logstash_port)
            logstash_handler.setFormatter(formatter)
            handlers.append(logstash_handler)
        except (socket.error, OSError) as e:
            # If Logstash is not available, log to console only
            print(f"Warning: Could not connect to Logstash: {e}", file=sys.stderr)

    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, log_level.upper()))
    root_logger.handlers = handlers

    # Set log level for third-party libraries
    logging.getLogger('uvicorn').setLevel(logging.WARNING)
    logging.getLogger('celery').setLevel(logging.WARNING)
    logging.getLogger('sqlalchemy').setLevel(logging.WARNING)

    return root_logger


# Create module-level logger (will be initialized when setup_logging is called)
logger = logging.getLogger(__name__)
