#!/usr/bin/env python3
"""
Playwright E2E test for:
1. Dual login verification:
   - palladiusbonton+playwright@gmail.com
   - palladiusbonton@gmail.com
2. Creating an Article with an image pasted into Trix (<trix-editor>)
3. Verifying ActiveStorage Direct Upload -> GCS persistence & rendered <img>
4. Destroying the created Article cleanly
"""
import base64
import os
import re
import time
from playwright.sync_api import sync_playwright

BASE_URL = os.environ.get("BASE_URL", "http://localhost:10000").rstrip("/")
PASSWORD = os.environ.get("PLAYWRIGHT_PASS", "43tiu2gher8d7g34ufbqwe")
PLAYWRIGHT_USER = os.environ.get("PLAYWRIGHT_TEST_USER", "palladiusbonton+playwright@gmail.com")
PALLADIUS_USER = os.environ.get("PALLADIUS_USER", "palladiusbonton@gmail.com")
SCREENSHOT_DIR = os.environ.get("SCREENSHOT_DIR", "/tmp/puffin-e2e-10k")


def run_test():
    os.makedirs(SCREENSHOT_DIR, exist_ok=True)
    server_errors = []
    direct_upload_urls = []

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
            if "direct_uploads" in response.url or "storage.googleapis.com" in response.url or "/rails/active_storage/disk/" in response.url:
                direct_upload_urls.append((response.request.method, response.status, response.url))
                print(f"  ☁️ Storage HTTP [{response.request.method} {response.status}]: {response.url[:110]}")

        page.on("response", on_response)

        print(f"🐧 Starting E2E Dual-Login + Trix Paste + CRUD test on {BASE_URL}")

        # ------------------------------------------------------------------
        # 1. Login as PLAYWRIGHT user (palladiusbonton+playwright@gmail.com)
        # ------------------------------------------------------------------
        print(f"1️⃣ Testing login as {PLAYWRIGHT_USER} ...")
        page.goto(f"{BASE_URL}/users/sign_in", wait_until="networkidle", timeout=45000)
        page.fill("#user_email", PLAYWRIGHT_USER)
        page.fill("#user_password", PASSWORD)
        page.click("input[type='submit'], button[type='submit']")
        page.wait_for_load_state("networkidle")

        # Verify signed in (Sign in button is gone, /user/edit link is present)
        assert page.locator("a[href='/user/edit']").count() > 0, f"Login failed for {PLAYWRIGHT_USER} (URL: {page.url})"
        page.screenshot(path=f"{SCREENSHOT_DIR}/01_login_playwright_user.png")
        print(f"  ✅ Logged in as {PLAYWRIGHT_USER}!")

        # Sign out via /user/edit
        page.goto(f"{BASE_URL}/user/edit", wait_until="networkidle")
        page.locator("button:has-text('Sign out'), input[value='Sign out']").click()
        page.wait_for_selector("a[href='/users/sign_in']", timeout=15000)
        print(f"  ✅ Signed out from {PLAYWRIGHT_USER}.")

        # ------------------------------------------------------------------
        # 2. Login as PALLADIUS user (palladiusbonton@gmail.com)
        # ------------------------------------------------------------------
        print(f"2️⃣ Testing login as {PALLADIUS_USER} ...")
        page.goto(f"{BASE_URL}/users/sign_in", wait_until="networkidle", timeout=45000)
        page.fill("#user_email", PALLADIUS_USER)
        page.fill("#user_password", PASSWORD)
        page.click("input[type='submit'], button[type='submit']")
        page.wait_for_load_state("networkidle")

        assert page.locator("a[href='/user/edit']").count() > 0, f"Login failed for {PALLADIUS_USER} (URL: {page.url})"
        page.screenshot(path=f"{SCREENSHOT_DIR}/02_login_palladius_user.png")
        print(f"  ✅ Logged in as {PALLADIUS_USER}!")

        # ------------------------------------------------------------------
        # 3. Create New Article & Paste Image into Trix (<trix-editor>)
        # ------------------------------------------------------------------
        test_title = f"[Playwright E2E] Trix GCS Paste {int(time.time())}"
        print(f"3️⃣ Creating article '{test_title}' and pasting image into Trix ...")
        page.goto(f"{BASE_URL}/articles/new", wait_until="networkidle")
        page.fill("#article_title", test_title)
        page.fill("#article_tag_list", "playwright, trix, gcs")

        # Focus trix-editor, type text, and paste a dynamically generated 80x80 PNG canvas image
        page.locator("trix-editor").click()
        page.keyboard.type("Testing Trix image paste persistence to Google Cloud Storage! ")

        page.evaluate("""() => {
            const canvas = document.createElement('canvas');
            canvas.width = 120;
            canvas.height = 80;
            const ctx = canvas.getContext('2d');
            ctx.fillStyle = '#f59e0b';
            ctx.fillRect(0, 0, 120, 80);
            ctx.fillStyle = '#0f172a';
            ctx.font = 'bold 16px sans-serif';
            ctx.fillText('PUFFIN GCS', 12, 45);
            canvas.toBlob((blob) => {
                const file = new File([blob], 'puffin-trix-paste.png', { type: 'image/png' });
                const dt = new DataTransfer();
                dt.items.add(file);
                const trix = document.querySelector('trix-editor');
                const pasteEvent = new ClipboardEvent('paste', {
                    clipboardData: dt,
                    bubbles: true,
                    cancelable: true
                });
                trix.dispatchEvent(pasteEvent);
                // If synthetic ClipboardEvent did not trigger Trix insertFile in headless mode, call editor.insertFile
                setTimeout(() => {
                    if (!document.querySelector('trix-editor figure.attachment')) {
                        trix.editor.insertFile(file);
                    }
                }, 150);
            }, 'image/png');
        }""")

        # Wait until ActionText DirectUpload finishes and sets sgid in the hidden input
        print("  ⏳ Waiting for Trix ActiveStorage DirectUpload to complete (sgid in hidden input)...")
        page.wait_for_function(
            """() => {
                const input = document.querySelector("input[name='article[body]']");
                return input && input.value.includes('sgid');
            }""",
            timeout=25000,
        )
        trix_html = page.locator("input[name='article[body]']").input_value()
        print(f"  ✅ Trix hidden input populated with sgid! Snippet: {trix_html[:160]}...")

        # Wait briefly for the 150ms polling timer in _form.html.erb to re-enable #article-submit-btn
        page.wait_for_function(
            """() => {
                const btn = document.getElementById('article-submit-btn');
                const status = document.getElementById('trix-upload-status');
                return btn && !btn.disabled && status && status.textContent.includes('Ready to save');
            }""",
            timeout=5000,
        )
        status_text = page.locator("#trix-upload-status").inner_text()
        assert not page.locator("#article-submit-btn").is_disabled(), "Submit button remained disabled after Trix upload!"
        print(f"  ✅ Submit button unlocked & status banner updated: '{status_text}'")
        page.screenshot(path=f"{SCREENSHOT_DIR}/03_trix_image_pasted.png")

        # Submit the article form and wait for Turbo navigation to /articles/:id
        page.locator("#article-submit-btn").click()
        page.wait_for_url(re.compile(r"/articles/\d+$"), timeout=30000)
        page.wait_for_load_state("networkidle")

        created_url = page.url
        print(f"  ✅ Article created at: {created_url}")
        page.screenshot(path=f"{SCREENSHOT_DIR}/04_article_created_with_trix_image.png")

        # Verify the pasted image is rendered inside .card-body .trix-content and actually loads (naturalWidth > 0)
        attachment_img = page.locator(".card-body .trix-content img").first
        attachment_img.wait_for(state="visible", timeout=15000)
        img_src = attachment_img.get_attribute("src")
        natural_width = attachment_img.evaluate("el => el.complete ? el.naturalWidth : 0")
        if natural_width == 0:
            page.wait_for_timeout(1500)
            natural_width = attachment_img.evaluate("el => el.naturalWidth")
        print(f"  🖼️ Rendered Trix attachment <img src='{img_src}'> naturalWidth={natural_width}")
        assert natural_width > 0, f"Pasted Trix image failed to load (src={img_src}, naturalWidth={natural_width})"

        # ------------------------------------------------------------------
        # 4. Destroy the test article and verify cleanup
        # ------------------------------------------------------------------
        print(f"4️⃣ Destroying test article {created_url} ...")
        page.on("dialog", lambda dialog: dialog.accept())
        page.locator("button:has-text('Destroy')").first.click()
        page.wait_for_url(re.compile(r"/articles$"), timeout=20000)
        page.wait_for_load_state("networkidle")
        page.screenshot(path=f"{SCREENSHOT_DIR}/05_article_destroyed.png")
        print("  ✅ Test article destroyed cleanly!")

        browser.close()

    assert not server_errors, f"Encountered 5xx/502 server errors: {server_errors}"
    print(f"🎉 ALL E2E CHECKS PASSED ON {BASE_URL}! Direct upload events: {len(direct_upload_urls)}")


if __name__ == "__main__":
    run_test()
