# Paysera Open Design — session handoff

Snapshot of the deployment for the next session. Operational details live in
[`README.md`](README.md); this file is the "where we are + what's next" pickup.

## TL;DR — what's live

- **URL:** https://design.paysera.engineering — Google SSO (oauth2-proxy, only `@paysera.net`).
- **Where:** GCP project `pt-ai-hub`, VM `open-design` (europe-west1-b, e2-standard-2, **no external IP**, egress via Cloud NAT). Image `europe-west1-docker.pkg.dev/pt-ai-hub/open-design/od-paysera:latest`.
- **Ingress:** Cloudflare Tunnel (`design.paysera.engineering` → `oauth2-proxy:4180` → daemon, `OD_DISABLE_API_AUTH=1`).
- **Fork:** `paysera/open-design` @ branch `deploy/paysera-gcp` (all changes committed).
- **Telemetry:** off (`metrics:false, content:false`).

## Agents (verified live)

| Agent | Status | Models | Path |
|---|---|---|---|
| **Claude Code** | ✅ | `vertex_ai/claude-opus-4-8` (default), `…sonnet-4-6`, `…haiku-4-5` | litellm gateway → Vertex |
| **Codex** | ✅ | `gpt-5.5` (default, reasoning medium) | litellm gateway, **Responses API** (`wire_api=responses`) |
| **Gemini CLI** | ✅ | `gemini-3.1-pro-preview`, `gemini-3.5-flash` | **direct** Google AI Studio key (bypasses the gateway) |
| Antigravity | ❌ not viable | — | `agy` needs **interactive Google login**; no headless/env auth → can't run server-side |

Model pickers are **curated to the latest only** (`claude.ts` and `gemini.ts`
forked; legacy ids removed). Default design system = built-in **`paysera`**
(`app-config.designSystemId=paysera`), set durably by the VM startup script.

### Model-name quirks (important)
- **Claude:** the gateway routes Claude to Vertex **only under `vertex_ai/…` names**; the bare `claude-opus-4-8` still hits a disabled direct-Anthropic route (400). Always use the `vertex_ai/` prefix.
- **Codex:** litellm serves `/v1/responses` (not `/v1/chat/completions` for codex ≥0.141). Config in `/home/open-design/.codex/config.toml` (provider `paysera-gateway`, `wire_api=responses`).
- **Gemini:** the gemini CLI can't take an OpenAI base URL, so it talks to Google directly with `GEMINI_API_KEY`. This **bypasses the central litellm gateway** (no central billing/audit for Gemini). Gemini models are *also* reachable via the gateway (`vertex_ai/gemini-3.5-flash` etc.) if a gateway-routed path is ever preferred.
- **Live artifact:** `GET /api/live-artifacts/:id/preview` and `POST .../refresh` are loopback-only upstream (desktop-app design); behind our proxy the daemon never sees a loopback peer/host/origin, so they 403'd. Relaxed in `routes/live-artifact.ts` to pass when `OD_DISABLE_API_AUTH=1` (trusted proxy). Sensitive loopback-only endpoints (daemon shutdown, db vacuum, connector OAuth) deliberately stay strict — verified still 403 from a non-loopback peer.

## Gateway (shared — not ours to freely change)

`paysera-llm-gateway` / Cloud Run `litellm-proxy`. Routes to Vertex in
`paysera-llm-gateway` (the team fixed it from the old org-policy-blocked
`vertex-darbuotojams`). Models registry is in the litellm DB
(`STORE_MODEL_IN_DB=True`), managed via the litellm Admin UI. Changing it
affects all consumers.

## Secrets (Secret Manager, project pt-ai-hub)

All present with versions: `open-design-cloudflared-token`,
`open-design-oauth-client-id`, `open-design-oauth-client-secret`,
`open-design-oauth-cookie-secret`, `open-design-litellm-key`,
`open-design-github-token`, `open-design-gemini-key`. Loaded into the container
at boot by `startup-script.sh` → `/opt/open-design/app.env`. The litellm virtual
key is reused as `OPENAI_API_KEY` for Codex.

> Hygiene: the local transfer file `~/Development/PE/design-secrets/.env` holds
> these in plaintext — **shred it** once nothing else needs re-loading.

## Operations quick-ref

```bash
# SSH (IAP, no public IP)
gcloud compute ssh open-design --zone europe-west1-b --project pt-ai-hub --tunnel-through-iap

# Rebuild image from source (claude/gemini def changes need this full build)
gcloud builds submit . --project pt-ai-hub --region europe-west1 --config deploy/paysera/cloudbuild-from-source.yaml
# Incremental layer-only patch (Dockerfile changes on top of current image)
gcloud builds submit /tmp/odpatch --project pt-ai-hub --region europe-west1 --tag <image>:latest

# Roll the VM (re-pull image + reload secrets + re-set default DS)
gcloud compute instances reset open-design --zone europe-west1-b --project pt-ai-hub
#   or, without reboot, on the VM:  sudo google_metadata_script_runner startup

# Terraform (compose / infra changes)
cd deploy/paysera/terraform && GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)" terraform apply
```

Build context: a repo-root `.gcloudignore` trims to the needed dirs — keep
root-trim patterns **anchored** (`/plugins/*`), or an unanchored `plugins/*`
also matches `packages/contracts/src/plugins` and breaks the daemon build.

## Not done / next session

1. **Phase 2 — ownership RBAC** (the original "Google-Drive" model): identity
   middleware reading oauth2-proxy's `X-Auth-Request-Email`, `owner_email` on
   projects, `requireProjectEdit` guard on mutation endpoints
   (choke-point `getProject` in `apps/daemon/src/db.ts`), copy-project endpoint,
   share dialog. Testable by injecting `X-Auth-Request-Email` at the daemon.
2. **Cost guard:** the litellm virtual key has a $200 budget cap; Gemini usage
   is **outside** the gateway (direct key) so it isn't covered by that cap —
   add a budget/alerts on the AI Studio key if Gemini sees heavy use.
3. **Cosmetic:** a few large PNG reference screenshots in the design-system
   preview gallery still use `../assets/*` paths (SVH logos were inlined and
   render fine). Inline/data-URI them if the gallery needs to be pixel-perfect.
4. **Antigravity:** revisit only if a headless/service-account auth path appears
   upstream; today it's interactive-login only.

## What "shared multi-user" means today

Access is SSO-gated (any `@paysera.net` user logs in and uses the shared
workspace + the default Paysera design system). It is **not** per-user isolated
yet — everyone sees/edits all projects. Per-user ownership is Phase 2 above.
