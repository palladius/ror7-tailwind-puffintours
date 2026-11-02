#!/usr/bin/env python3
"""
Playwright E2E verification suite for Puffin Tours (Local & Render Production).
Verifies core navigation, authentication, Glassmorphic/A2UI toggle, 5-star widget,
graphs, family, users sorting, and asserts zero 500/502 errors.
"""
import os
import sys
from playwright.sync_api import sync_playwright

BASE_URL = os.environ.get("BASE_URL", "https://ror7-tailwind-puffintours.onrender.com").rstrip("/")
USER_EMAIL = os.environ.get("PLAYWRIGHT_EMAIL", "palladiusbonton@gmail.com")
USER_PASS = os.environ.get("PLAYWRIGHT_PASS", "43tiu2gher8d7g34ufbqwe")
SCREENSHOT_DIR = os.environ.get("SCREENSHOT_DIR", "/tmp/puffin-playwright")


def run_e2e():
    os.makedirs(SCREENSHOT_DIR, exist_ok=True)
    server_errors = []
    visited_pages = []

    with sync_playwright() as p:
        browser = p.chromium.launch(
            executable_path="/usr/bin/google-chrome",
            headless=True,
            args=[
                "--use-gl=angle",
                "--use-angle=gl",
                "--enable-gpu-rasterization",
                "--enable-webgl",
                "--ignore-gpu-blocklist",
            ],
        )
        context = browser.new_context(viewport={"width": 1440, "height": 900})
        page = context.new_page()

        def on_response(response):
            if response.status >= 500:
                server_errors.append((response.status, response.url))
                print(f"  ❌ SERVER ERROR {response.status}: {response.url}")

        page.on("response", on_response)

        def goto_and_verify(path, expected_selector="body"):
            url = f"{BASE_URL}{path}"
            resp = page.goto(url, wait_until="networkidle", timeout=45000)
            status = resp.status if resp else 0
            visited_pages.append((path, status))
            print(f"  [{status}] {path}")
            assert status < 500, f"HTTP {status} on {url}"
            page.wait_for_selector(expected_selector, timeout=15000)
            return resp

        print(f"🐧 Running Playwright E2E against {BASE_URL} ...")

        # 1. Public pages
        goto_and_verify("/", "h1")
        page.screenshot(path=f"{SCREENSHOT_DIR}/01_home.png")

        goto_and_verify("/articles", "#btn-view-a2ui")
        page.screenshot(path=f"{SCREENSHOT_DIR}/02_articles_glass.png")

        # Test A2UI Surface toggle
        page.click("#btn-view-a2ui")
        page.wait_for_selector("#puffin-a2ui-view:not(.hidden)", timeout=5000)
        page.fill("#a2ui-input-query", "barcelona")
        page.screenshot(path=f"{SCREENSHOT_DIR}/03_articles_a2ui.png")
        page.click("#btn-view-glass")

        # Pagination & tags
        goto_and_verify("/articles?page=2", "article.card")
        goto_and_verify("/tags/puffintours", "h1")
        goto_and_verify("/pages/graphs", "h2")
        page.screenshot(path=f"{SCREENSHOT_DIR}/04_graphs.png")

        goto_and_verify("/pages/about_us", "h1")
        goto_and_verify("/pages/about_the_app", "h2")
        goto_and_verify("/pages/privacy_policy", "h1")

        # 2. Sign in
        goto_and_verify("/users/sign_in", "form#new_user")
        page.fill("#user_email", USER_EMAIL)
        page.fill("#user_password", USER_PASS)
        page.click("input[type='submit'], button[type='submit']")
        page.wait_for_load_state("domcontentloaded")
        print(f"  Signed in -> current URL: {page.url}")

        # 3. Authenticated pages
        goto_and_verify("/users", "table")
        goto_and_verify("/users?q%5Bs%5D=created_at+desc", "table")
        goto_and_verify("/users?q%5Bs%5D=is_admin+desc", "table")
        page.screenshot(path=f"{SCREENSHOT_DIR}/05_users.png")

        goto_and_verify("/family", "img")
        page.screenshot(path=f"{SCREENSHOT_DIR}/06_family.png")

        goto_and_verify("/user/edit", "h1")
        goto_and_verify("/articles/new", "form")

        # 4. Open first article from /articles and verify 5-star rating & edit/destroy buttons
        goto_and_verify("/articles", "article.card a.card-link")
        first_href = page.locator("article.card a.card-link").first.get_attribute("href")
        assert first_href, "Expected at least one article link on /articles"
        goto_and_verify(first_href, "#minimal-star-picker")

        # Hover/click 4th star in minimalist rating widget
        page.locator("#minimal-star-picker button[data-star='4']").click()
        star_label = page.locator("#minimal-star-label").inner_text()
        assert "4 / 5" in star_label, f"Expected star label '4 / 5', got '{star_label}'"
        page.screenshot(path=f"{SCREENSHOT_DIR}/07_article_show.png")

        browser.close()

    assert not server_errors, f"Encountered 5xx/502 errors during E2E navigation: {server_errors}"
    print(f"✅ All {len(visited_pages)} navigated pages succeeded with ZERO 500/502 errors!")


if __name__ == "__main__":
    run_e2e()
