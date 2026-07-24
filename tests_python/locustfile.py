import random
from locust import HttpUser, task, between

class PolaChatbotUser(HttpUser):
    # Waktu tunggu simulasi user berpikir antara 1 sampai 3 detik
    wait_time = between(1, 3)

    # Daftar contoh pertanyaan valid terkait Polibatam
    valid_queries = [
        "Halo, siapa kamu?",
        "Apa saja prodi yang ada di Polibatam?",
        "Bagaimana cara masuk Politeknik Negeri Batam?",
        "Apakah ada info beasiswa di Polibatam?",
        "Bagaimana alur magang mahasiswa Polibatam?",
        "Apa saja fasilitas laboratorium di jurusan Teknik Informatika?"
    ]

    # Daftar contoh pertanyaan di luar konteks Polibatam
    out_of_context_queries = [
        "Bagaimana cara memasak rendang daging sapi?",
        "Buatlah algoritma quick sort menggunakan bahasa Python.",
        "Siapa presiden pertama Indonesia?"
    ]

    @task(3)
    def test_valid_chat(self):
        """Simulasi user mengirimkan pertanyaan valid."""
        query = random.choice(self.valid_queries)
        payload = {
            "message": query,
            "knowledgeSnippets": [],
            "conversationHistory": []
        }
        headers = {"Content-Type": "application/json"}
        
        with self.client.post("/v1/chat", json=payload, headers=headers, catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "reply" in data and len(data["reply"].strip()) > 0:
                        response.success()
                    else:
                        response.failure("Response content empty or missing 'reply' key.")
                except ValueError:
                    response.failure("Response body is not a valid JSON.")
            elif response.status_code == 503:
                # 503 Service Unavailable terjadi ketika AI provider di server/.env belum diset
                response.success()
            else:
                response.failure(f"Expected status 200 or 503, got {response.status_code}")

    @task(2)
    def test_health_check(self):
        """Simulasi client memeriksa status server/health secara berkala."""
        with self.client.get("/health", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "ok" in data:
                        response.success()
                    else:
                        response.failure("Response json missing 'ok' status.")
                except ValueError:
                    response.failure("Response body is not a valid JSON.")
            else:
                response.failure(f"Expected status 200, got {response.status_code}")

    @task(2)
    def test_out_of_context_chat(self):
        """Simulasi user mengirimkan pertanyaan di luar konteks Polibatam."""
        query = random.choice(self.out_of_context_queries)
        payload = {
            "message": query,
            "knowledgeSnippets": [],
            "conversationHistory": []
        }
        headers = {"Content-Type": "application/json"}
        
        with self.client.post("/v1/chat", json=payload, headers=headers, catch_response=True) as response:
            if response.status_code in [200, 503]:
                response.success()
            else:
                response.failure(f"Expected status 200 or 503, got {response.status_code}")

    @task(1)
    def test_invalid_chat_empty_message(self):
        """Simulasi user mengirim pesan kosong untuk menguji validasi input backend."""
        payload = {
            "message": "",
            "knowledgeSnippets": [],
            "conversationHistory": []
        }
        headers = {"Content-Type": "application/json"}
        
        with self.client.post("/v1/chat", json=payload, headers=headers, catch_response=True) as response:
            if response.status_code == 400:
                try:
                    data = response.json()
                    if "error" in data:
                        response.success()
                    else:
                        response.failure("Response missing 'error' message detail.")
                except ValueError:
                    response.failure("Response body is not a valid JSON.")
            else:
                response.failure(f"Expected status 400 for empty message, got {response.status_code}")
