import os
import sys
import time
import socket
import subprocess
import pytest
import requests
from dotenv import load_dotenv

# Load environment variables from both root and server directory
root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load_dotenv(os.path.join(root_dir, ".env"))
load_dotenv(os.path.join(root_dir, "server", ".env"))

def is_port_open(host, port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.5)
        try:
            s.connect((host, port))
            return True
        except (socket.timeout, ConnectionRefusedError):
            return False

@pytest.fixture(scope="session")
def backend_server():
    """Fixture to ensure backend Node.js server is running."""
    host = "127.0.0.1"
    port = 8787
    url = f"http://{host}:{port}"
    
    # Check if backend is already running
    if is_port_open(host, port):
        print(f"\n[Fixture] Backend server already running on {url}")
        yield url
        return

    # Start the backend server as a subprocess
    server_dir = os.path.join(root_dir, "server")
    print(f"\n[Fixture] Starting backend Node.js server in {server_dir}...")
    
    # Verify node_modules exists, run npm install if not
    if not os.path.isdir(os.path.join(server_dir, "node_modules")):
        print("[Fixture] node_modules not found, installing packages...")
        subprocess.run("npm install", shell=True, cwd=server_dir, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    process = subprocess.Popen(
        ["node", "index.js"],
        cwd=server_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        shell=True if sys.platform == "win32" else False
    )

    # Wait for the server to become healthy
    success = False
    for _ in range(20):
        time.sleep(0.5)
        try:
            res = requests.get(f"{url}/health", timeout=1)
            if res.status_code == 200:
                success = True
                break
        except requests.exceptions.RequestException:
            pass

    if not success:
        # Get errors if it failed to start
        stdout, stderr = process.communicate(timeout=1)
        process.terminate()
        raise RuntimeError(
            f"Failed to start backend server. stdout: {stdout}, stderr: {stderr}"
        )

    print(f"[Fixture] Backend server started successfully on {url}")
    yield url

    # Terminate the server
    print("\n[Fixture] Stopping backend Node.js server...")
    process.terminate()
    try:
        process.wait(timeout=3)
    except subprocess.TimeoutExpired:
        process.kill()


@pytest.fixture(scope="session")
def proxy_server(backend_server):
    """Fixture to ensure the Python website proxy server is running."""
    host = "127.0.0.1"
    port = 8080
    url = f"http://{host}:{port}"

    if is_port_open(host, port):
        print(f"\n[Fixture] Proxy server already running on {url}")
        yield url
        return

    print(f"\n[Fixture] Starting Python website proxy server on port {port}...")
    
    # Set required environment variables
    env = os.environ.copy()
    env["POLA_BACKEND_PROXY"] = backend_server
    env["POLA_SITE_ROOT"] = os.path.join(root_dir, "releases", "POLA-website")
    
    # Fallback to source website folder if releases hasn't been built yet
    if not os.path.exists(os.path.join(env["POLA_SITE_ROOT"], "index.html")):
        env["POLA_SITE_ROOT"] = os.path.join(root_dir, "website")

    script_path = os.path.join(root_dir, "scripts", "pola_site_server.py")
    
    process = subprocess.Popen(
        [sys.executable, script_path, str(port)],
        cwd=root_dir,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    # Wait for the proxy server to become healthy
    success = False
    for _ in range(10):
        time.sleep(0.5)
        if is_port_open(host, port):
            success = True
            break

    if not success:
        stdout, stderr = process.communicate(timeout=1)
        process.terminate()
        raise RuntimeError(
            f"Failed to start proxy server. stdout: {stdout}, stderr: {stderr}"
        )

    print(f"[Fixture] Proxy server started successfully on {url}")
    yield url

    # Terminate the server
    print("\n[Fixture] Stopping proxy server...")
    process.terminate()
    try:
        process.wait(timeout=3)
    except subprocess.TimeoutExpired:
        process.kill()


@pytest.fixture(scope="function")
def driver():
    """Fixture to launch a headless Selenium WebDriver (Chrome)."""
    from selenium import webdriver
    from selenium.webdriver.chrome.service import Service as ChromeService
    from selenium.webdriver.chrome.options import Options as ChromeOptions
    from webdriver_manager.chrome import ChromeDriverManager

    options = ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")
    
    # Handle SSL certificates just in case
    options.add_argument("--ignore-certificate-errors")

    print("\n[Fixture] Launching Selenium Chrome driver...")
    service = ChromeService(ChromeDriverManager().install())
    chrome_driver = webdriver.Chrome(service=service, options=options)
    
    # Set page load timeout
    chrome_driver.set_page_load_timeout(30)
    # Set implicit wait time
    chrome_driver.implicitly_wait(5)

    yield chrome_driver

    print("\n[Fixture] Closing Selenium Chrome driver...")
    chrome_driver.quit()
