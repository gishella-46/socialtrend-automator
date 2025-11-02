"""Authentication routes for FastAPI.

NOTE: This application uses flat access control - all authenticated users
have full access to all endpoints. No role-based restrictions are applied.
Authentication (JWT token) is still required for protected routes.
"""

from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel

from app.services.auth_service import (
    create_access_token,
    verify_password,
    get_current_active_user,
    ACCESS_TOKEN_EXPIRE_MINUTES,
)
from app.utils.logging import logger

router = APIRouter(prefix="/automation", tags=["authentication"])


class Token(BaseModel):
    """Token response model."""
    access_token: str
    token_type: str


class UserResponse(BaseModel):
    """User response model."""
    username: str


# In production, implement proper user database lookup
# For now, use a demo user validation
DEMO_USERS = {
    "admin": {
        "username": "admin",
        # password: secret
        "hashed_password": "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW",
    }
}


@router.post("/token", response_model=Token, summary="OAuth2 token endpoint")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    OAuth2 password flow login endpoint.
    
    Returns JWT access token for authenticated users.
    """
    user = DEMO_USERS.get(form_data.username)

    if not user or not verify_password(form_data.password, user["hashed_password"]):
        logger.warning("Failed login attempt", extra={"username": form_data.username})
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user["username"]}, expires_delta=access_token_expires
    )

    logger.info("User authenticated", extra={"username": user["username"]})

    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=UserResponse, summary="Get current user")
async def read_users_me(current_user: dict = Depends(get_current_active_user)):
    """Get current authenticated user information."""
    return {"username": current_user["username"]}
