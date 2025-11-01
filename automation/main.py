"""SocialTrend Automation API - FastAPI application for AI and auto-upload services."""

import os

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

try:
    from prometheus_fastapi_instrumentator import Instrumentator  # type: ignore
    PROMETHEUS_AVAILABLE = True
except ImportError:
    PROMETHEUS_AVAILABLE = False

# Import all modules first (PEP 8)
from app.api.routes import ai_caption, auth, caption, trends, upload
from app.utils.logging import logger, setup_logging

# Load environment variables
load_dotenv()

# Setup JSON logging
setup_logging(os.getenv('LOG_LEVEL', 'INFO'))

# Initialize FastAPI app
app = FastAPI(
    title="SocialTrend Automation API",
    description="Microservice for AI-powered social media automation",
    version="1.0.0",
    docs_url="/docs",  # Swagger UI
    redoc_url="/redoc",  # ReDoc
    openapi_url="/openapi.json",
)

# CORS middleware - Production security (whitelist frontend domain)
# Update FRONTEND_URL in .env for production
FRONTEND_URL = os.getenv("FRONTEND_URL", "http://localhost:8080")
ALLOWED_ORIGINS = [
    FRONTEND_URL,
    "http://localhost",
    "http://localhost:8080",
    "https://yourdomain.com",  # Update with production domain
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,  # Whitelist only frontend domains
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
    expose_headers=["*"],
)

# Prometheus metrics instrumentation
if PROMETHEUS_AVAILABLE:
    Instrumentator().instrument(app).expose(app)
    logger.info("Prometheus instrumentation enabled")
else:
    logger.warning(
        "Prometheus instrumentator not available - "
        "install with: pip install prometheus-fastapi-instrumentator"
    )

# Include routers
app.include_router(auth.router)  # Authentication routes
app.include_router(upload.router)
app.include_router(trends.router)
app.include_router(caption.router)
app.include_router(ai_caption.router)


@app.on_event("startup")
async def startup_event():
    """Run on application startup."""
    logger.info("Starting SocialTrend Automation API", extra={"version": "1.0.0"})


@app.on_event("shutdown")
async def shutdown_event():
    """Run on application shutdown."""
    logger.info("Shutting down SocialTrend Automation API")


@app.get("/")
async def root():
    """Root endpoint that returns API information and status."""
    return {
        "message": "SocialTrend Automation API",
        "status": "running",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
async def health():
    """Health check endpoint to verify service availability."""
    return {"status": "healthy", "service": "socialtrend-automation"}
