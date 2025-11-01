"""PostgreSQL database connection using SQLAlchemy async."""

import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker  # type: ignore  # pylint: disable=import-error
from sqlalchemy.orm import declarative_base  # type: ignore  # pylint: disable=import-error
from dotenv import load_dotenv

load_dotenv()

# Database URL from environment
DB_URL = os.getenv(
    'DB_URL',
    f"postgresql+asyncpg://{os.getenv('DB_USERNAME', 'socialtrend_user')}:"
    f"{os.getenv('DB_PASSWORD', 'socialtrend_pass')}@"
    f"{os.getenv('DB_HOST', 'db')}:"
    f"{os.getenv('DB_PORT', '5432')}/"
    f"{os.getenv('DB_DATABASE', 'socialtrend_db')}"
)

# Create async engine
engine = create_async_engine(
    DB_URL,
    echo=False,
    future=True,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
)

# Create async session factory
AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

# Base class for models
Base = declarative_base()


async def get_db():
    """Dependency for getting database session."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
