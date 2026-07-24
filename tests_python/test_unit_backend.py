import requests

def test_backend_health(backend_server):
    """Test that the /health endpoint returns a 200 OK and valid JSON structure."""
    url = f"{backend_server}/health"
    response = requests.get(url)
    
    assert response.status_code == 200, f"Expected 200 OK, got {response.status_code}"
    
    data = response.json()
    assert "ok" in data, "Response should contain 'ok' status"
    assert "provider" in data, "Response should indicate the AI provider"
    assert "model" in data, "Response should indicate the active AI model"
    
    # Assert type formats
    assert isinstance(data["ok"], bool)
    assert isinstance(data["provider"], str)
    assert isinstance(data["model"], str)


def test_backend_chat_empty_message(backend_server):
    """Test that POSTing an empty message returns a 400 Bad Request."""
    url = f"{backend_server}/v1/chat"
    payload = {"message": ""}
    
    response = requests.post(url, json=payload)
    
    assert response.status_code == 400, f"Expected 400 Bad Request, got {response.status_code}"
    data = response.json()
    assert "error" in data, "Response should contain 'error' key"
    assert "wajib diisi" in data["error"].lower(), "Error message should say message is required"


def test_backend_chat_missing_message_field(backend_server):
    """Test that POSTing a body without a 'message' field returns a 400 Bad Request."""
    url = f"{backend_server}/v1/chat"
    payload = {"knowledgeSnippets": []}
    
    response = requests.post(url, json=payload)
    
    assert response.status_code == 400, f"Expected 400 Bad Request, got {response.status_code}"
    data = response.json()
    assert "error" in data
    assert "wajib diisi" in data["error"].lower()


def test_backend_chat_response_format(backend_server):
    """Test that a valid chat message receives a 200 OK and returns a proper JSON structure."""
    url = f"{backend_server}/v1/chat"
    payload = {
        "message": "Halo, siapa kamu?",
        "conversationHistory": []
    }
    
    response = requests.post(url, json=payload)
    
    # In case the provider is 'none' (not configured), the backend will return 503 Service Unavailable
    # We should handle this scenario gracefully in testing.
    health_data = requests.get(f"{backend_server}/health").json()
    if health_data["provider"] == "none":
        assert response.status_code == 503, f"Expected 503 Service Unavailable when AI is not configured, got {response.status_code}"
        assert "belum dikonfigurasi" in response.json()["error"]
    else:
        assert response.status_code == 200, f"Expected 200 OK, got {response.status_code}"
        data = response.json()
        assert "reply" in data, "Response should contain 'reply' text"
        assert "provider" in data, "Response should contain 'provider' name"
        assert isinstance(data["reply"], str)
        assert len(data["reply"].strip()) > 0
