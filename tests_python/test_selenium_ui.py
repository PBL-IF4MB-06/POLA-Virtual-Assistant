import time
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def test_landing_page_title(driver, proxy_server):
    """Test that the POLA landing page loads with the correct title."""
    driver.get(proxy_server)
    
    # Wait for the title to load and assert it matches
    WebDriverWait(driver, 10).until(
        lambda d: d.title != ""
    )
    
    expected_title = "POLA - Download Aplikasi Chatbot AI Polibatam"
    assert driver.title == expected_title, f"Expected title '{expected_title}', got '{driver.title}'"


def test_landing_page_branding(driver, proxy_server):
    """Test that the POLA landing page contains the correct branding logo and text."""
    driver.get(proxy_server)
    
    # Locate branding in the header
    brand_logo = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "header .brand img"))
    )
    brand_text = driver.find_element(By.CSS_SELECTOR, "header .brand span")
    
    assert brand_logo.is_displayed(), "Brand logo image is not displayed"
    assert brand_text.text == "POLA", f"Expected brand text 'POLA', got '{brand_text.text}'"


def test_download_cards_presence(driver, proxy_server):
    """Test that the four download cards (Android, iOS, Web, Windows) are present on the landing page."""
    driver.get(proxy_server)
    
    # Find all download cards in the download-grid
    cards = WebDriverWait(driver, 10).until(
        EC.presence_of_all_elements_located((By.CSS_SELECTOR, ".download-card"))
    )
    
    assert len(cards) == 4, f"Expected 4 download cards, found {len(cards)}"
    
    # Verify titles of the download cards
    card_titles = [card.find_element(By.TAG_NAME, "h3").text for card in cards]
    expected_titles = ["Android", "iPhone / iPad", "Web / Browser", "Windows"]
    
    for title in expected_titles:
        assert title in card_titles, f"Download card for '{title}' is missing"


def test_open_web_app_button(driver, proxy_server):
    """Test that the 'Buka Aplikasi Web' button in the header navigates to the web app path."""
    driver.get(proxy_server)
    
    # Find the 'Buka Aplikasi Web' button in the header
    web_app_btn = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//a[contains(text(), 'Buka Aplikasi Web')]"))
    )
    
    web_app_btn.click()
    
    # Wait for the URL to change to the web app path
    WebDriverWait(driver, 10).until(
        EC.url_contains("/app/")
    )
    
    current_url = driver.current_url
    assert "/app/" in current_url, f"Expected URL to contain '/app/', got '{current_url}'"


def test_features_section(driver, proxy_server):
    """Test that the features section is correctly displayed with the key features listed."""
    driver.get(proxy_server)
    
    # Scroll to features section
    features_section = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, "fitur"))
    )
    assert features_section.is_displayed(), "Features section is not visible"
    
    # Verify we have at least some features listed
    features = driver.find_elements(By.CSS_SELECTOR, "#fitur .feature")
    assert len(features) >= 4, f"Expected at least 4 features, found {len(features)}"
    
    # Verify some key feature texts
    feature_headings = [f.find_element(By.TAG_NAME, "h4").text for f in features]
    key_features = ["💬 Chatbot AI", "🏫 Info Kampus", "🔔 Notifikasi", "📱 Multi Platform"]
    
    for k in key_features:
        assert any(k in h for h in feature_headings), f"Key feature '{k}' not found in the list"
