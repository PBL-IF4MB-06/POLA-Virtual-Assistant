import os
import pytest
import requests

def get_ai_provider(backend_server):
    try:
        res = requests.get(f"{backend_server}/health")
        if res.status_code == 200:
            return res.json().get("provider", "none")
    except Exception:
        pass
    return "none"

@pytest.fixture(autouse=True)
def skip_if_no_ai(backend_server):
    provider = get_ai_provider(backend_server)
    if provider == "none":
        pytest.skip("AI provider is not configured. Skip testing AI model responses.")

def ask_pola(backend_server, message, snippets=None, history=None):
    url = f"{backend_server}/v1/chat"
    payload = {
        "message": message,
        "knowledgeSnippets": snippets or [],
        "conversationHistory": history or []
    }
    response = requests.post(url, json=payload)
    assert response.status_code == 200, f"Chat request failed: {response.text}"
    return response.json()["reply"]

def test_ai_language_indonesian(backend_server):
    """Test that the AI chatbot replies in Indonesian and is polite."""
    reply = ask_pola(backend_server, "Halo, perkenalkan dirimu secara singkat.")
    
    # Check that common Indonesian words are present
    indonesian_words = ["saya", "adalah", "pola", "politeknik", "negeri", "batam", "asisten", "bantu", "halo", "hai"]
    reply_lower = reply.lower()
    
    match_count = sum(1 for word in indonesian_words if word in reply_lower)
    assert match_count >= 1, f"Expected reply to be in Indonesian. Reply was: {reply}"


def test_ai_confinement_out_of_context(backend_server):
    """Test that POLA declines answering queries that are clearly outside Polibatam context."""
    # Questions that have nothing to do with Polibatam
    out_of_context_queries = [
        "Bagaimana cara membuat sushi khas Jepang di rumah?",
        "Tolong buatkan kode program Java untuk mengurutkan array dengan bubble sort.",
        "Siapakah astronot pertama yang mendarat di bulan?"
    ]
    
    for query in out_of_context_queries:
        reply = ask_pola(backend_server, query)
        reply_lower = reply.lower()
        
        # POLA should decline or state that it is an assistant for Polibatam.
        # Key decline markers based on system prompt rules
        decline_markers = ["maaf", "tidak dapat", "tolak", "polibatam", "pola", "hanya", "asisten resmi", "luar", "konteks"]
        match_count = sum(1 for marker in decline_markers if marker in reply_lower)
        
        assert match_count >= 1, f"POLA did not seem to decline the out-of-context query: '{query}'. Reply: {reply}"


def test_ai_confinement_in_context(backend_server):
    """Test that POLA answers correctly when queries are within the Polibatam context."""
    query = "Apa saja jurusan atau program studi yang ada di Politeknik Negeri Batam?"
    reply = ask_pola(backend_server, query)
    reply_lower = reply.lower()
    
    # Should contain references to Polibatam departments/majors (e.g. teknik, informatika, elektro, bisnis, mesin)
    context_keywords = ["teknik", "informatika", "elektro", "mesin", "manajemen", "bisnis", "akuntansi", "prodi", "jurusan", "polibatam"]
    match_count = sum(1 for word in context_keywords if word in reply_lower)
    
    assert match_count >= 2, f"POLA reply did not contain expected Polibatam context keywords. Reply: {reply}"


def test_ai_knowledge_snippet_priority(backend_server):
    """Test that POLA prioritizes and answers using facts from the provided knowledgeSnippets."""
    message = "Berapa kuota penerimaan untuk program studi baru Animasi 3D Polibatam?"
    
    # We supply a mock knowledge snippet with a specific, fake fact
    snippets = [
        {
            "sourceTitle": "Brosur Animasi 3D 2026",
            "text": "Untuk tahun akademik 2026, program studi Animasi 3D Politeknik Negeri Batam hanya membuka kuota penerimaan sebanyak 42 mahasiswa baru melalui jalur prestasi."
        }
    ]
    
    reply = ask_pola(backend_server, message, snippets=snippets)
    reply_lower = reply.lower()
    
    # The reply must capture the specific detail (42 mahasiswa / 42) from the snippet
    assert "42" in reply_lower or "empat puluh dua" in reply_lower, (
        f"POLA failed to prioritize or extract info from the knowledge snippet. Reply: {reply}"
    )


def test_ai_custom_dataset_integration(backend_server):
    """Test that the custom dataset file (dataset_custom.txt) is successfully read and used as context."""
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    dataset_path = os.path.join(root_dir, "dataset_custom.txt")
    
    # Backup existing dataset content
    original_content = ""
    if os.path.exists(dataset_path):
        with open(dataset_path, "r", encoding="utf-8") as f:
            original_content = f.read()
            
    # Inject a temporary unique custom fact
    temp_fact_key = "KODE_UNIQ_TES_AI_2026"
    temp_fact_value = "Gedung baru Technopreneurship Polibatam diresmikan oleh Gubernur Kepulauan Riau dengan nama Gedung Hang Nadim pada 17 Agustus 2026."
    temp_content = f"{original_content}\n\n{temp_fact_key}: {temp_fact_value}\n"
    
    try:
        with open(dataset_path, "w", encoding="utf-8") as f:
            f.write(temp_content)
            
        # Query the chatbot about this temporary fact
        query = f"Apa nama gedung baru Technopreneurship Polibatam menurut {temp_fact_key}?"
        reply = ask_pola(backend_server, query)
        reply_lower = reply.lower()
        
        # Verify the chatbot uses the injected fact
        assert "hang nadim" in reply_lower or "17 agustus" in reply_lower or "gubernur" in reply_lower, (
            f"AI response did not reflect facts from dataset_custom.txt. Reply: {reply}"
        )
        
    finally:
        # Restore the original dataset contents
        with open(dataset_path, "w", encoding="utf-8") as f:
            f.write(original_content)
