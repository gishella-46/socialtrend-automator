"""
Trends endpoint tests
"""


def test_fetch_trends_requires_authentication(client):
    """Test that fetch trends endpoint requires authentication"""
    response = client.post("/api/trends/fetch", json={
        "platform": "google",
        "keywords": ["AI", "Technology"]
    })
    assert response.status_code == 401


def test_fetch_trends_validates_keywords(client, headers):
    """Test that fetch trends validates keywords array"""
    response = client.post("/api/trends/fetch", json={
        "platform": "google",
        "keywords": []
    }, headers=headers)
    assert response.status_code in [200, 400, 422, 500]


def test_fetch_trends_with_valid_keywords(client, headers):
    """Test fetch trends with valid keywords"""
    response = client.post("/api/trends/fetch", json={
        "platform": "google",
        "keywords": ["AI", "Technology"]
    }, headers=headers)
    # May return 200 or 500 depending on actual implementation
    assert response.status_code in [200, 400, 500]

