# Local Port 10000 (Prod DB) + Remote Render E2E & Trix-to-GCS Image Persistence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Run Puffin Tours locally on port `10000` in `RAILS_ENV=production` connected to the Prod Cloud SQL DB (`34.65.100.166`), verify Trix image paste/upload persistence to Google Cloud Storage (`GCS`), and execute automated Playwright E2E tests against both `http://localhost:10000` and `https://ror7-tailwind-puffintours.onrender.com` (testing login as `palladius` and `playwright`, creating & destroying a post, and pasting an image into Trix).

**Architecture:**
1. **GCS Billing & Credential Bridge**: Currently `gs://puffin-tours-public` (project `puffin-tours`) has `billingEnabled: false` (`billingAccounts/019DCC-D30845-2DD27B`), causing `Google::Cloud::PermissionDeniedError: accountDisabled` on upload, whereas `ric-cccwiki` (`billingAccounts/019B50-4CED52-737F15`) and `ror-goldie` (`billingAccounts/008A6A-41C6DD-0C2DB7`) have active billing. Additionally, [`entrypoint-8080.sh`](file:///home/riccardo/git/ror7-tailwind-puffintours/entrypoint-8080.sh) and [`config/storage.yml`](file:///home/riccardo/git/ror7-tailwind-puffintours/config/storage.yml) will support `GCP_SA_JSON_BASE64` (materialized to `/tmp/gcp-sa.json` at container boot, matching the pattern in `genai-kids-stories` / `ror7-scubatracker-ng25`) so Render can also persist Trix uploads directly to GCS.
2. **Playwright E2E Suite (`test/playwright/e2e_trix_and_crud.py`)**: A dedicated Playwright script that logs in as both `palladiusbonton@gmail.com` and `palladiusbonton+playwright@gmail.com`, creates a new Article, simulates pasting/attaching a PNG image inside `<trix-editor>`, verifies the `<action-text-attachment>` + `ActiveStorage::Blob` (`service_name: "gcs"`), and then destroys the test Article cleanly so Prod DB stays clean.

**Tech Stack:** Rails 8.1.4, Ruby 3.4.5, ActiveStorage (`google-cloud-storage`), ActionText / Trix 2.1.15, PostgreSQL (Cloud SQL `34.65.100.166`), Playwright (Python + Chrome RTX 5080 WebGL flags).

**Spec:** User request in conversation `14e63e40-d934-40c0-ac59-0e24b5435f7a` (2026-11-02).

## Global Constraints

- Dual-login verification required: `palladiusbonton@gmail.com` AND `palladiusbonton+playwright@gmail.com` (password `43tiu2gher8d7g34ufbqwe`).
- Local production server must run on `PORT=10000` (`http://localhost:10000`) connected to Prod DB (`34.65.100.166`, database `ror7-tailwind-puffintours`).
- Every test article created against Prod DB during E2E testing must be destroyed at the end of the test (`🗑️ Destroy`) and verified gone.
- Do NOT `git push` without explicit user permission.

## Review Focus

- **Disabled GCP Billing on `puffin-tours`**: `gs://puffin-tours-public` currently returns `403 accountDisabled` until either billing is re-linked on project `puffin-tours` OR `BUCKET`/`PROJECT_ID` is pointed to an active project (`ric-cccwiki` or `ror-goldie`).
- **Missing GCS Key File on Render**: `private/puffin-tours-secret-key.json` is gitignored; Render needs `GCP_SA_JSON_BASE64` decoded into `/tmp/gcp-sa.json` by `entrypoint-8080.sh` so `config/storage.yml` and `config/environments/production.rb` enable `service: GCS` on Render.
- **Trix Direct Upload CORS**: When pasting an image into `<trix-editor>`, `@rails/activestorage` uploads directly from the browser via `PUT` to `https://storage.googleapis.com/<bucket>/...`; bucket CORS must allow `PUT`/`POST`/`GET` from `*` (already verified on `puffin-tours-public`, must also be set if switching bucket).
- **Playwright User Exists in Prod DB**: Verify `palladiusbonton+playwright@gmail.com` exists in Prod Cloud SQL (`34.65.100.166`) with password `43tiu2gher8d7g34ufbqwe` before running the dual-login E2E test.
- **Trix Asynchronous Attachment Upload Completion**: Playwright must wait for `<action-text-attachment sgid="...">` (without `[progress]`) before clicking `Create Article`, otherwise the form submits before the GCS direct upload finishes.

---

### Task 1: Enable Active GCS Bucket & Env-Var Credential Support (`GCP_SA_JSON_BASE64`)

**Files:**
- Modify: `entrypoint-8080.sh:1-25`
- Modify: `config/storage.yml:9-30`
- Modify: `config/environments/production.rb:40-43`
- Modify: `app/helpers/gcp_helper.rb:2-5`
- Test: `test/integration/routes_and_502_prevention_test.rb`

**Interfaces:**
- Produces: `GcpHelper#gcp_keyfile_path` returning the first existing path among `Rails.root.join("private/puffin-tours-secret-key.json")` and `Pathname.new("/tmp/gcp-sa.json")`.

- [x] **Step 1: Write failing test for `/tmp/gcp-sa.json` / `GCP_SA_JSON_BASE64` credential detection**

```ruby
test "gcp_credentials_available? detects /tmp/gcp-sa.json when present" do
  tmp_key = "/tmp/gcp-sa.json"
  File.write(tmp_key, '{"type":"service_account"}')
  assert Object.new.extend(GcpHelper).gcp_credentials_available?
ensure
  File.delete(tmp_key) if File.exist?(tmp_key)
end
```

- [x] **Step 2: Run test to verify it fails when `private/puffin-tours-secret-key.json` is absent**

Run: `bundle exec rails test test/integration/routes_and_502_prevention_test.rb`
Expected: FAIL or verify credential path resolution in `GcpHelper`, `config/storage.yml`, and `config/environments/production.rb`.

- [x] **Step 3: Update `entrypoint-8080.sh`, `config/storage.yml`, `config/environments/production.rb`, and `app/helpers/gcp_helper.rb`**

In `entrypoint-8080.sh`, decode `GCP_SA_JSON_BASE64` into `/tmp/gcp-sa.json` if set. In `config/storage.yml`, `config/environments/production.rb`, and `app/helpers/gcp_helper.rb`, check both `private/puffin-tours-secret-key.json` and `/tmp/gcp-sa.json`. Ensure the target GCS project/bucket has active billing and CORS `origin: ["*"]`, `methods: ["GET", "PUT", "POST", "HEAD", "OPTIONS"]`, `headers: ["*"]`.

- [x] **Step 4: Verify GCS upload & delete from Ruby CLI and run Rails tests**

Run: `bundle exec rails test` and the Ruby GCS upload/delete probe against `ENV["BUCKET"]`.
Expected: `Upload OK` and `24 runs, 0 failures, 0 errors`.

---

### Task 2: Boot Local Production Server on Port `10000` Connected to Prod DB (`34.65.100.166`)

**Files:**
- Modify: `config/initializers/riccardo.rb:30-35` (ensure `localhost` and `127.0.0.1` work on port `10000` in `RAILS_ENV=production`)
- Test: `test/playwright/e2e_trix_and_crud.py`

**Interfaces:**
- Consumes: `.envrc` (`DATABASE_HOST=34.65.100.166`, `DATABASE_NAME=ror7-tailwind-puffintours`), Task 1 GCS config.
- Produces: Running server at `http://localhost:10000` in `RAILS_ENV=production` and verified `palladiusbonton+playwright@gmail.com` user in Prod DB.

- [x] **Step 1: Ensure `palladiusbonton+playwright@gmail.com` exists in Prod DB (`34.65.100.166`)**

Run a one-line `RAILS_ENV=production bundle exec rails runner` check that finds or creates `palladiusbonton+playwright@gmail.com` with password `43tiu2gher8d7g34ufbqwe`.

- [x] **Step 2: Start local server on `PORT=10000` with `RAILS_ENV=production`**

Run: `PORT=10000 RAILS_ENV=production ./entrypoint-8080.sh`
Expected: `Listening on http://0.0.0.0:10000` and `curl -i http://localhost:10000/up` returns `200 OK`.

---

### Task 3: Write & Run Playwright E2E Test for Dual Login, Article Create/Destroy, and Trix Image Paste (`GCS`)

**Files:**
- Create: `test/playwright/e2e_trix_and_crud.py`

**Interfaces:**
- Consumes: `BASE_URL` (`http://localhost:10000` first, then `https://ror7-tailwind-puffintours.onrender.com`).
- Produces: Verified screenshots in `/tmp/puffin-e2e-10k/` and `/tmp/puffin-e2e-render/` proving login for both users, Trix image paste + GCS blob persistence, and article deletion.

- [x] **Step 1: Create `test/playwright/e2e_trix_and_crud.py`**

Write the Playwright E2E script that:
1. Logs in as `palladiusbonton+playwright@gmail.com` (`/users/sign_in`), verifies login success, and logs out (`/user/edit` -> `Sign out`).
2. Logs in as `palladiusbonton@gmail.com` (`/users/sign_in`).
3. Navigates to `/articles/new`, fills `Title` (`[Playwright E2E] Trix GCS Test`), and dispatches a `ClipboardEvent('paste')` / file attachment with a generated valid PNG image directly onto `trix-editor`.
4. Waits for `trix-editor figure.attachment[data-trix-attachment]` to complete its ActiveStorage upload (`sgid` present in `<input type="hidden" id="article_body_trix_input_article...">`), then submits the form.
5. On the resulting `/articles/:id` show page, asserts `200 OK`, verifies the rendered `<figure class="attachment ..."><img src="..."></figure>` inside `.card-body`, and checks that the image loads (`naturalWidth > 0`).
6. Clicks `🗑️ Destroy` (accepting the `turbo_confirm` dialog) and verifies redirect to `/articles` with `"Article was successfully destroyed."`.

- [x] **Step 2: Run `test/playwright/e2e_trix_and_crud.py` against `http://localhost:10000`**

Run: `BASE_URL=http://localhost:10000 UV_CACHE_DIR=/tmp/uv-cache UV_LINK_MODE=copy UV_INDEX_URL=https://pypi.org/simple uv run --with playwright python3 test/playwright/e2e_trix_and_crud.py`
Expected: PASS with zero 500/502 errors, verified GCS blob upload in Trix, and clean article destruction.

- [ ] **Step 3: Deploy `v0.7.2` to Render (with user permission) and run `test/playwright/e2e_trix_and_crud.py` against `https://ror7-tailwind-puffintours.onrender.com`**

Run: `BASE_URL=https://ror7-tailwind-puffintours.onrender.com UV_CACHE_DIR=/tmp/uv-cache UV_LINK_MODE=copy UV_INDEX_URL=https://pypi.org/simple uv run --with playwright python3 test/playwright/e2e_trix_and_crud.py`
Expected: PASS on remote Render instance with both logins, post creation, Trix image paste, and post destruction verified.
