# syntax=docker/dockerfile:1
# Houston Autonomous Agent Runtime & Host Dockerfile
# Clones upstream gethouston/houston directly to ensure reproducible builds & clean updates.

FROM node:22-bookworm-slim AS builder

ENV PNPM_HOME=/pnpm \
    PATH=/pnpm:$PATH

RUN corepack enable && \
    apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone upstream release
ARG HOUSTON_REPO=https://github.com/gethouston/houston.git
ARG HOUSTON_TAG=main
RUN git clone --depth 1 --branch ${HOUSTON_TAG} ${HOUSTON_REPO} .

# Build Workspace Bundles
RUN pnpm install --frozen-lockfile \
      --filter houston-ai \
      --filter @houston/runtime... \
      --filter @houston/host...

RUN node selfhost/bundle.mjs

# Build Frontend Web UI if available
RUN if [ -d "packages/web" ]; then \
      VITE_NEW_ENGINE=1 pnpm --filter houston-web build && \
      mkdir -p /build/dist/web && cp -R packages/web/dist/* /build/dist/web/; \
    fi

# -----------------------------------------------------------------------------
# Runtime Production Image
# -----------------------------------------------------------------------------
FROM node:22-bookworm-slim AS runner

ENV PNPM_HOME=/pnpm \
    PATH=/pnpm:$PATH

RUN corepack enable && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      git python3 curl wget ca-certificates procps && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built bundle and node dependencies
COPY --from=builder /build/package.json /build/pnpm-lock.yaml /build/pnpm-workspace.yaml ./
COPY --from=builder /build/patches/ ./patches/
COPY --from=builder /build/ui/agent-schemas/ ./ui/agent-schemas/
COPY --from=builder /build/packages/ ./packages/
COPY --from=builder /build/dist /app/dist

RUN pnpm install --frozen-lockfile --prod \
      --filter @houston/runtime... \
      --filter @houston/host...

RUN ln -s /app/node_modules/.pnpm/node_modules /app/dist/host/node_modules 2>/dev/null || true && \
    ln -s /app/node_modules/.pnpm/node_modules /app/dist/runtime/node_modules 2>/dev/null || true

RUN mkdir -p /data/workspaces /data/db && chown -R node:node /app /data

ENV NODE_ENV=production \
    HOUSTON_HOME=/data \
    HOUSTON_HOST_BIND=0.0.0.0 \
    HOUSTON_HOST_PORT=4318 \
    HOUSTON_RUNTIME_COMMAND="node --enable-source-maps /app/dist/runtime/main.mjs"

USER node
EXPOSE 4318

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.HOUSTON_HOST_PORT||4318)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "--enable-source-maps", "dist/host/main.mjs"]
