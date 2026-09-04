# 🚀 Houston AI Self-Hosted Agent Host

Autonomous agent host and runtime for `roadtotech.me`, providing AI agents with tool-use, workspace execution, and streaming endpoints.

---

## 🏗️ Architecture & Configuration

- **Domain**: `https://houston.roadtotech.me`
- **Internal Port**: `4318`
- **Orchestrator**: Managed via `appctl`
- **Network**: `proxy-net` behind Traefik v3 wildcard SSL

---

## 🚀 Deployment

```bash
# Start Houston stack
appctl up houston

# View status
appctl info houston
```

---

## 📄 License
This deployment configuration is released into the public domain under the [Unlicense](LICENSE).
