"""
Pytest configuration and fixtures for FastAPI tests
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI app"""
    return TestClient(app)


@pytest.fixture
def mock_auth_token():
    """Mock authentication token for testing"""
    return "test_token_12345"


@pytest.fixture
def headers(mock_auth_token):
    """Authorization headers for authenticated requests"""
    return {"Authorization": f"Bearer {mock_auth_token}"}
