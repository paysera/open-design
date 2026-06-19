# syntax=docker/dockerfile:1
#
# Paysera Open Design — custom container image
# ============================================
#
# This image layers Paysera-specific runtime needs on top of the upstream
# Open Design daemon image. The base image (ghcr.io/nexu-io/od:latest) is the
# Alpine/musl, Node 24 runtime built from deploy/Dockerfile: WORKDIR /app,
# runs as user "open-design" (uid/gid 1001), serves the daemon on port 7456,
# entrypoint /sbin/tini --, CMD `node apps/daemon/dist/cli.js --no-open`.
#
# Two things the base image intentionally omits but a Paysera deployment needs:
#   1. The Anthropic Claude Code CLI ("claude" binary). The daemon spawns
#      `claude -p ...` for the Claude runtime (apps/daemon/src/runtimes/defs/
#      claude.ts: bin: 'claude'); the base image does NOT bundle it, so we
#      install it here.
#   2. The Paysera brand design system, baked into the built-in catalogue at
#      /app/design-systems/paysera so it is available without a runtime mount.
#
# Build context MUST be the repo root (see cloudbuild.yaml) so the
# `COPY design-systems/paysera ...` step can find the baked design system.

FROM ghcr.io/nexu-io/od:latest

# ---------------------------------------------------------------------------
# Root layer: system deps + global CLI install.
# The base image runs as the unprivileged "open-design" user; switch to root
# for package installation, then drop back down before the image is used.
# ---------------------------------------------------------------------------
USER root

# Pin a recent Claude Code release for reproducible builds. The npm package
# @anthropic-ai/claude-code installs the `claude` binary on PATH — exactly the
# binary the daemon's Claude runtime spawns (`bin: 'claude'`).
ARG CLAUDE_CODE_VERSION=2.1.183

# - libc6-compat + gcompat: glibc shims for Alpine/musl. The Claude Code CLI
#   ships prebuilt native helpers (e.g. ripgrep) linked against glibc; without
#   these shims they fail to load on musl with "Error loading shared library".
# - git: the CLI shells out to git for repo awareness; the slim base does not
#   include it.
# Then install the CLI globally and clean the npm cache to keep the layer lean.
RUN apk add --no-cache libc6-compat gcompat git \
    && npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
    && npm cache clean --force \
    && claude --version

# ---------------------------------------------------------------------------
# Bake the Paysera design system into the built-in catalogue.
# Built-in design systems live at /app/design-systems/<slug>/; placing it here
# (rather than mounting at runtime) means the brand DS ships inside the image
# and is owned by the runtime user. Source path is relative to the repo-root
# build context.
# ---------------------------------------------------------------------------
COPY --chown=open-design:open-design design-systems/paysera /app/design-systems/paysera

# ---------------------------------------------------------------------------
# Drop privileges back to the runtime user. Keep the base image's
# ENTRYPOINT (/sbin/tini --) and CMD (node apps/daemon/dist/cli.js --no-open)
# unchanged — they are inherited and we deliberately do not override them.
# ---------------------------------------------------------------------------
USER open-design
