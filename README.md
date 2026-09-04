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

## 📜 Upstream Attribution & Acknowledgments

- **Upstream Project**: [Houston](https://github.com/gethouston/houston)
- **Official Site**: [gethouston.ai](https://gethouston.ai)
- **Engine Container**: `ghcr.io/gethouston/houston-engine-pod`
- **Upstream License**: Apache License 2.0 / MIT

This homelab repository provides the infrastructure automation, Traefik ingress configuration, and deployment definitions for hosting Houston in the `roadtotech.me` cluster. All original Houston branding, logos, and engine code are the property of their respective creators at [gethouston](https://github.com/gethouston).

---

## 📄 License
This deployment configuration and homelab integration is released into the public domain under [The Unlicense](LICENSE).
