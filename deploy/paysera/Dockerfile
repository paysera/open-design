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

# Base Open Design runtime image. Defaults to the upstream published image, but
# is overridable so a self-built base (e.g. od-base:latest produced from this
# repo's deploy/Dockerfile in the same Cloud Build run) can be layered on when
# the upstream GHCR image is not pullable from the build environment.
ARG BASE_IMAGE=ghcr.io/nexu-io/od:latest
FROM ${BASE_IMAGE}

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
# - bash: Claude Code's Bash tool requires a real POSIX shell. The slim Alpine
#   base only ships busybox `sh`; without bash + a SHELL env, every Bash tool
#   call fails with "No suitable shell found. Claude CLI requires a Posix shell
#   environment." This breaks connectors and any agent shell step.
# Then install the CLI globally and clean the npm cache to keep the layer lean.
RUN apk add --no-cache libc6-compat gcompat git bash github-cli \
    && npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
    && npm cache clean --force \
    && claude --version \
    && gh --version | head -1

# Claude Code's Bash tool resolves the shell from $SHELL; point it at bash.
ENV SHELL=/bin/bash

# GitHub connector (`od tools connectors github-design-context`) clones repos
# via git/gh. For PRIVATE repos (e.g. paysera/cc-design-system) it needs auth.
# Install a git credential helper that injects the runtime $GH_TOKEN, so both
# `git clone` and `gh` authenticate when GH_TOKEN is present in the container
# env. No token is baked into the image; it is supplied at runtime via secret.
RUN printf '#!/bin/sh\n[ "$1" = "get" ] || exit 0\necho username=x-access-token\necho "password=$GH_TOKEN"\n' > /usr/local/bin/gh-credential-helper \
    && chmod +x /usr/local/bin/gh-credential-helper \
    && git config --system credential."https://github.com".helper /usr/local/bin/gh-credential-helper

# ---------------------------------------------------------------------------
# Bake the Paysera design system into the built-in catalogue.
# Built-in design systems live at /app/design-systems/<slug>/; placing it here
# (rather than mounting at runtime) means the brand DS ships inside the image
# and is owned by the runtime user. Source path is relative to the repo-root
# build context.
# ---------------------------------------------------------------------------
# The base image creates the open-design user with `adduser -H` (no home dir),
# so $HOME (/home/open-design) does not exist and is not writable. Claude Code
# writes ~/.claude on shell init; a missing/unwritable HOME makes every Bash
# tool call fail with a "home directory permission issue". Create it, owned by
# the runtime user.
RUN mkdir -p /home/open-design && chown open-design:open-design /home/open-design

# Codex CLI (OpenAI), wired to the Paysera litellm gateway's OpenAI-compatible
# endpoint. A custom model provider with wire_api="chat" is required because
# codex 0.141+ only supports the Responses API (wire_api="responses"); the
# litellm gateway serves /v1/responses (verified 200 for gpt-5.5). The API key
# is injected at runtime via OPENAI_API_KEY (env_key below); no secret is baked.
ARG CODEX_VERSION=latest
RUN npm install -g @openai/codex@${CODEX_VERSION} && npm cache clean --force && codex --version | head -1
RUN mkdir -p /home/open-design/.codex && \
    printf 'model = "gpt-5.5"\nmodel_provider = "paysera-gateway"\n\n[model_providers.paysera-gateway]\nname = "Paysera litellm gateway"\nbase_url = "https://litellm-proxy-3qgmggattq-ew.a.run.app/v1"\nenv_key = "OPENAI_API_KEY"\nwire_api = "responses"\n' > /home/open-design/.codex/config.toml && \
    chown -R open-design:open-design /home/open-design/.codex

COPY --chown=open-design:open-design design-systems/paysera /app/design-systems/paysera

# ---------------------------------------------------------------------------
# Drop privileges back to the runtime user. Keep the base image's
# ENTRYPOINT (/sbin/tini --) and CMD (node apps/daemon/dist/cli.js --no-open)
# unchanged — they are inherited and we deliberately do not override them.
# ---------------------------------------------------------------------------
USER open-design
