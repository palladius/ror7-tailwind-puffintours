This is a rails app for Family trips and articles.

## Ruby

Often you'll get ruby issues because you're using the wrong ruby (/usr/bin, or /opt/brew/ , ...). The right ruby should be from rbenv which flexibly honours the local `.ruby-version`.

## MCP

* Use playwright to do UI testing. Find USER/PASS in `.envrc` grepping PLAYWRIGHT you'll find proper credentials.

## Feedback loop

* do NOT run `just dev`, I'll run it for you and server will be on port 3000.
* Check logs in `log/` folder.
* To test the app live, you can use `curl` for simple things (200 vs 500, or text grepping); for UI complicated stuff, use MCP+Playwright.
* Upon every commit, a Cloud Build will trigger a build and deploy on Cloud Run.

## features and bugs

### Initial work
1. Ensure all bugs you find locally are persisted on github as issus.
2. Move all local TODOs into proper issues and delete from here (better place)

### Feature/bugs cycle

1. Always work on a GH issue, use `gh` to control it (no curl/fetches!).
2. Work locally with a plan under docs/issues/PLAN-(ISSUEID).md.
3. This plan of action shjould contain checkboxes, so it can be edited in real time. I use Gemini CLI and it tends to crash, so we need to be able to pick up stuff from where we left it. A local file.
4. Ok to do commits as they are meaningful, should be ONE commit per 1 feature, with two exceptions:
   1.  If the feature is a complicated, ok to break it down
   2.  If we need to deploy asap to Cloud Run and see the effect in prod, then its ok to do a micro commit/push.
5. Do NOT git push without user permission.
6. After a push, it would be nice to add a comment to the GH issue, and add the git commit hash to the comment for github cross-linking.

## Local file

* All ENV vars are in `.envrc`
* GCP config is under `gcp/`.
