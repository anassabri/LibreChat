---
name: Package availability
description: Distinguish package metadata availability from successful installation on this imported project.
---

Do not treat a successful `npm view` lookup as evidence that Replit can install
that package version.

**Why:** During import setup, metadata queries worked while package tarball
requests repeatedly returned HTTP 404 through the package service, including
after trying the latest parent dependency.

**How to apply:** Require an actual successful install before attempting the
build. If the package service still fails, report the blocker rather than
bypassing its firewall or broadly changing the imported project's tooling.
