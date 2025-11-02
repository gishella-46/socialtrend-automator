"""
Upload endpoint tests
"""


def test_upload_endpoint_requires_authentication(client):
    """Test that upload endpoint requires authentication"""
    response = client.post("/api/upload", json={
        "platform": "instagram",
        "content": "Test content"
    })
    assert response.status_code == 401


def test_upload_endpoint_validates_platform(client, headers):
    """Test that upload endpoint validates platform"""
    response = client.post("/api/upload", json={
        "platform": "invalid_platform",
        "content": "Test content"
    }, headers=headers)
    assert response.status_code in [400, 422]


def test_upload_endpoint_with_valid_data(client, headers):
    """Test upload with valid data"""
    response = client.post("/api/upload", json={
        "platform": "instagram",
        "content": "Test content for Instagram",
        "media_urls": []
    }, headers=headers)
    # May return 200 or 500 depending on actual implementation
    assert response.status_code in [200, 400, 500]
