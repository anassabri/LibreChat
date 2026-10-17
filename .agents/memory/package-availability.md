---
name: Package availability
description: Distinguish package metadata availability from successful installation on this imported project.
---

Do not treat a successful `npm view` lookup as evidence that Replit can install
that package version.

**Why:** During import setup, metadata queries worked while package tarball
requests repeatedly returned HTTP 404. Later investigation found that npm's
download URL omitted the configured registry's `/npm/` prefix. The same
tarballs returned HTTP 200 through the correct Replit firewall endpoint.
The missing prefix caused a misleading “package unavailable” diagnosis;
correctly routed requests still passed through the same firewall.

**How to apply:** Require an actual successful install before attempting the
build. Compare failed tarball URLs with `npm config get registry` before
concluding packages are unavailable; test only through the configured firewall.
Preserve integrity hashes and use the correct firewall route, never an external
registry bypass. Internal lockfile URLs are Replit-specific; revisit them if
moving this project to another host. If the correctly routed package request
still fails, report the blocker rather than broadly changing the tooling.
