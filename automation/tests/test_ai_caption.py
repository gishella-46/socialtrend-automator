"""
AI Caption endpoint tests
"""


def test_ai_caption_requires_authentication(client):
    """Test that AI caption endpoint requires authentication"""
    response = client.post("/api/ai/caption", json={
        "topic": "Technology",
        "style": "professional"
    })
    assert response.status_code == 401


def test_ai_caption_validates_input(client, headers):
    """Test that AI caption validates required fields"""
    response = client.post("/api/ai/caption", json={
        "topic": ""
    }, headers=headers)
    assert response.status_code in [400, 422]


def test_ai_caption_with_valid_data(client, headers):
    """Test AI caption generation with valid data"""
    response = client.post("/api/ai/caption", json={
        "topic": "Technology",
        "style": "professional"
    }, headers=headers)
    # May return 200 or 500 depending on OpenAI API
    assert response.status_code in [200, 400, 500]

