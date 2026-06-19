# Paysera Open Design — GCP deployment

Shared, SSO-gated Open Design instance for Paysera, deployed to GCP project
**`pt-ai-hub`**, reachable at **`https://design.paysera.engineering`**.

This is the operational runbook. Architecture rationale lives in the PR /
session notes; this file is what you act on.

---

## 1. Architecture

```
 user (browser)
   │  https://design.paysera.engineering   (Cloudflare TLS)
   ▼
 Cloudflare edge ──► Cloudflare Tunnel (connector token)
   ▼
 GCE VM "open-design"  (europe-west1-b, NO external IP, egress via Cloud NAT)
   └─ docker compose:
        cloudflared      ── dials OUT to Cloudflare; routes hostname ─┐
        oauth2-proxy:4180 ◄──────────────────────────────────────────┘
          │  Google Workspace SSO, restricted to @paysera.net   ◄── AUTH HERE
          ▼
        open-design:7456  (daemon, OD_DISABLE_API_AUTH=1)
          │  spawns `claude` CLI ── ANTHROPIC_BASE_URL ─►
          ▼
        Paysera litellm-proxy (Cloud Run, paysera-llm-gateway) ─► Vertex Claude
```

- **Ingress**: a Cloudflare Tunnel (no public IP on the VM, no GCP load
  balancer — sidesteps org policy on external IPs). The connector dials out.
- **SSO**: `oauth2-proxy` on the VM (Cloudflare Access is not configured for the
  zone). Google Workspace login, restricted to `@paysera.net`. It forwards the
  authenticated email as `X-Auth-Request-Email` / `X-Forwarded-Email` — the
  identity header the phase‑2 ownership RBAC will consume.
- **Daemon**: `OD_DISABLE_API_AUTH=1` — auth is enforced entirely by
  oauth2-proxy in front; the daemon is never exposed except through the proxy.
- **Design system**: the Paysera brand DS (`design-systems/paysera/`) is baked
  into the image as a read-only built-in, so every project on the instance can
  pick "Paysera Design System" from the catalogue. Source of truth:
  [`paysera/cc-design-system`](https://github.com/paysera/cc-design-system).
- **Model**: Claude via the Paysera **litellm-proxy** (Anthropic-compatible,
  bare model names like `claude-sonnet-4-5`) → Vertex. Central billing/audit.
  A dedicated litellm virtual key (`open-design-shared`, $200 budget cap) is
  used; no direct Vertex IAM on the VM.

### GCP resources (all in `pt-ai-hub`, Terraform-managed)

`deploy/paysera/terraform/` creates: dedicated VPC `open-design-net` + `/28`
subnet (Private Google Access), Cloud Router + Cloud NAT, 3 firewall rules
(IAP-range SSH only, explicit egress, deny-public-ingress), least-privilege
SA `open-design-vm@pt-ai-hub.iam.gserviceaccount.com`, 5 Secret Manager
containers, a 50 GB data disk, and the Shielded VM `open-design` (`e2-standard-2`).

---

## 2. Current state / what's left

| Component | State |
|---|---|
| Fork `paysera/open-design`, branch `deploy/paysera-gcp` | ✅ |
| Paysera design system baked into the image | ✅ |
| Image `…/open-design/od-paysera:latest` in Artifact Registry | ✅ (built from source) |
| GCP infra (VPC/NAT/SA/disk/VM/secrets) via Terraform | ✅ applied |
| Secret: litellm key, oauth cookie secret | ✅ stored |
| Secret: **Google OAuth client id + secret** | ⛔ **needs you** — step 3a |
| Secret: **Cloudflare tunnel token** | ⛔ **needs you** — step 3b |
| Public URL live behind SSO | ⛔ after 3a + 3b + reboot |
| Phase‑2 ownership RBAC (owner-only edit + sharing) | ⛔ separate branch |

Until 3a/3b are done, `open-design` runs on the VM (verifiable internally via
IAP SSH), but `oauth2-proxy` and `cloudflared` stay down (no public URL).

---

## 3. The two human steps (unavoidable Google / Cloudflare security steps)

### 3a. Google OAuth Web client (for oauth2-proxy SSO)

Google shut down the IAP OAuth Admin API (2026), so a Web OAuth client must be
created in the console once.

1. **Console → APIs & Services → OAuth consent screen** (project `pt-ai-hub`):
   - User type **Internal** (Workspace `paysera.net`).
   - Add **`paysera.engineering`** to *Authorized domains* (verify the domain in
     the project if prompted).
2. **Console → APIs & Services → Credentials → Create credentials → OAuth client ID**:
   - Application type **Web application**.
   - **Authorized redirect URI**: `https://design.paysera.engineering/oauth2/callback`
   - Create → copy the **Client ID** and **Client secret**.
3. Store both into Secret Manager (values via stdin, never on the command line):
   ```bash
   printf '%s' '<CLIENT_ID>'     | gcloud secrets versions add open-design-oauth-client-id     --project pt-ai-hub --data-file=-
   printf '%s' '<CLIENT_SECRET>' | gcloud secrets versions add open-design-oauth-client-secret --project pt-ai-hub --data-file=-
   ```
   (Prefer pasting these in your own terminal so the values never enter a chat.)

### 3b. Cloudflare Tunnel (you create it in the UI)

1. **Cloudflare Zero Trust → Networks → Tunnels → Create a tunnel** (Cloudflared):
   - Name it e.g. `open-design`.
   - Copy the **connector token** (the `eyJ…` after `--token` in the install
     command). Do NOT run the cloudflared install command — the VM already runs
     the connector; it only needs the token.
2. **Public Hostname** tab → Add a public hostname:
   - Subdomain `design`, domain `paysera.engineering`.
   - Service: **`http://oauth2-proxy:4180`** (NOT the daemon directly — SSO must
     sit in front). Cloudflare auto-creates the proxied DNS record.
3. Store the token:
   ```bash
   printf '%s' '<TUNNEL_TOKEN>' | gcloud secrets versions add open-design-cloudflared-token --project pt-ai-hub --data-file=-
   ```

### 3c. Bring the full stack up

The VM reads secrets only at boot. After 3a + 3b, reboot it:

```bash
gcloud compute instances reset open-design --zone europe-west1-b --project pt-ai-hub
```

Then open `https://design.paysera.engineering` → Google login (paysera.net) →
Open Design with the Paysera design system.

---

## 4. Operations

**SSH (IAP, no public IP):**
```bash
gcloud compute ssh open-design --zone europe-west1-b --project pt-ai-hub --tunnel-through-iap
```

**On the VM:**
```bash
cd /opt/open-design
sudo docker compose --env-file app.env ps
sudo docker compose --env-file app.env logs -f open-design
sudo docker compose --env-file app.env logs -f oauth2-proxy
# re-read secrets + restart WITHOUT a reboot (re-runs the startup script):
sudo google_metadata_script_runner startup
```
(The reboot in 3c is the simplest way to re-run the startup script and reload
secrets into `app.env`.)

**Health check internally (before SSO is wired):**
```bash
# from an SSH session on the VM:
curl -s http://localhost:7456/api/health
```

---

## 5. Rebuild / redeploy the image

The upstream `ghcr.io/nexu-io/od` image is not pullable from our build
environment, so the image is built **from source in the same Cloud Build run**:
`deploy/Dockerfile` (daemon + web + baked design systems) → `deploy/paysera/Dockerfile`
(adds the Claude CLI) → push.

```bash
# from the repo root:
gcloud builds submit . \
  --project pt-ai-hub --region europe-west1 \
  --config /tmp/cloudbuild-combined.yaml      # (committed copy: see note below)
```
A committed equivalent of the combined config can live alongside
`deploy/paysera/cloudbuild.yaml`; the repo-root `.gcloudignore` keeps the build
context lean (anchor root-only trims with a leading `/` — an unanchored
`plugins/*` also matches `packages/contracts/src/plugins` and breaks the build).

Then roll the VM:
```bash
gcloud compute ssh open-design --zone europe-west1-b --project pt-ai-hub --tunnel-through-iap \
  --command 'cd /opt/open-design && sudo docker compose --env-file app.env pull && sudo docker compose --env-file app.env up -d'
```

## 6. Update the design system

Edit `design-systems/paysera/{DESIGN.md,tokens.css,components.html}` on the
`deploy/paysera-gcp` branch (keep the 9-section schema + WCAG AA), commit,
rebuild the image (§5), roll the VM. The DS is read-only on the instance by
design — users cannot edit the canonical brand; they pick it per project.

## 7. Cost (rough, EU)

`e2-standard-2` ~€48/mo + 50 GB pd-balanced ~€6/mo + Cloud NAT ~€32/mo + egress.
Model usage billed via the litellm key budget ($200 cap). Stop the VM
(`gcloud compute instances stop open-design …`) to pause compute cost.

## 8. Teardown

```bash
cd deploy/paysera/terraform
GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)" terraform destroy
# Secret containers have deletion protection off; data disk is destroyed too.
# Artifact Registry repo + images are not Terraform-managed — delete separately.
```

## 9. Phase 2 — multi-user ownership RBAC (planned)

Open Design has no built-in per-user model. The shared instance today lets every
authenticated user see/edit all projects. The planned fork (separate branch)
adds a Google-Drive-style model:

- identity middleware reading oauth2-proxy's `X-Auth-Request-Email`;
- `owner_email` on projects (set on create), a `requireProjectEdit` guard on the
  ~48 mutating endpoints (choke-point: `getProject` in `apps/daemon/src/db.ts`);
- "everyone can view/copy, only owner (or granted users / everyone) can edit",
  plus a copy-project endpoint and a share dialog.

This is logical RBAC, not OS-level isolation: agents still execute in one
container under one identity. True per-user isolation = per-user instances.
