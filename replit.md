# LibreChat on Replit

## Stack and layout

Keep the imported npm workspace structure: React/Vite in `client`, Express
wiring in `api`, and shared packages in `packages`. The project targets Node 24
(`.nvmrc`); Replit uses the Node 24 module. Follow `AGENTS.md` for code changes.

## Setup and run

1. Install the root npm dependencies using the existing `package-lock.json`.
2. Add a **MongoDB connection string** as `MONGO_URI` in Replit Secrets.
   Use a dedicated database for this instance. LibreChat writes its collections,
   indexes, seed data and credential metadata during startup. Ensure the MongoDB
   service allows connections from this workspace.
3. Configure an AI provider using the corresponding secret, such as
   `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`. Alternatively, LibreChat supports
   setting a provider's environment variable to the literal `user_provided` so
   users supply their own keys through its UI. Without a provider, AI chat cannot
   be verified.
4. Run the **LibreChat** workflow (`bash scripts/replit.sh`).
   The launcher builds missing workspace/frontend output with `npm run frontend`,
   then runs `npm run backend`. After source changes, rebuild explicitly with
   `npm run frontend` and restart the workflow.

The launcher binds the existing Express server, including the built frontend, to
`0.0.0.0:5000` and sets client/server URLs from the Replit development domain.
It requires `MONGO_URI` in the environment rather than inventing a database.
Optional Meilisearch and Redis services are not provisioned; search defaults to
disabled. No Docker or database migration/replacement is involved.

LibreChat's existing credential bootstrap generates private development keys in
the Git-ignored `.env.temp`. Keep that file private and persistent; do not print
or commit it. Before publishing, configure stable `CREDS_KEY`, `CREDS_IV`,
`JWT_SECRET` and `JWT_REFRESH_SECRET` through Secrets, preserving existing key
values if they have already encrypted stored credentials. Never publish using
workspace-local temporary keys. Production setup is separate from this
development launcher.

## Publishing dependency troubleshooting

The deployment package installer uses the npm registry configured in this
workspace:

```sh
npm config get registry
# http://package-firewall.replit.internal/npm/
```

If a publish fails during `npm install` with a 404 URL like
`http://package-firewall.replit.internal/npm-run-path/-/...`, compare it with the
configured registry. The request is missing the `/npm/` path prefix; this can
look like an unavailable package even though the package is present in Replit's
firewall.

For the current `npm-run-path` lock entries, the resolved URLs must retain the
prefix:

- `node_modules/npm-run-path` (4.0.1):
  `http://package-firewall.replit.internal/npm/npm-run-path/-/npm-run-path-4.0.1.tgz`
- `node_modules/lint-staged/node_modules/npm-run-path` (5.3.0):
  `http://package-firewall.replit.internal/npm/npm-run-path/-/npm-run-path-5.3.0.tgz`

To diagnose another package, check the exact tarball path through the configured
firewall endpoint. For this incident, the correctly prefixed URL returned HTTP
200 while the URL without `/npm/` returned 404.

When fixing this specific error, update only the affected `resolved` URLs in
`package-lock.json`. Preserve the locked versions and integrity hashes. Do not
change package versions, point npm at a public registry, or replace the package
manager as a workaround. Afterward, run the normal Replit-managed npm install
and `npm run frontend` before publishing. A successful metadata lookup alone
does not prove the tarball can be installed.

These internal firewall URLs are Replit-specific. If moving the project to
another host, restore portable registry URLs using that host's normal package
installation workflow.

## MongoDB Atlas access from a published deployment

A publish can build successfully and still fail its port/readiness check if
LibreChat cannot connect to MongoDB. This server connects to MongoDB before it
starts listening, so an Atlas network rejection can appear as “port 5000 was
never opened” or repeated HTTP 500 health checks.

Check the deployment runtime logs for Atlas messages about an IP not being
whitelisted before changing the port or startup command. The public IP added
for the Replit development workspace does not automatically allow the published
Autoscale service. Atlas must allow the published service's outbound IP address
or range as well. Replit's available documentation does not specify a fixed
Autoscale egress IP, so confirm the production egress address/range rather than
assuming the development IP applies.

Keep the Atlas access list as narrow as the production network allows. An entry
of `0.0.0.0/0` permits connection attempts from any IPv4 address and should not
be left in place as a production setting. After adding the correct production
egress entry, republish and confirm the runtime logs show MongoDB connected and
the service listening on the configured port.

## Current verification status

The corrected dependency install and `npm run frontend` have succeeded in the
workspace. The LibreChat workflow starts, connects to MongoDB, and serves the
login page. The latest production attempt built successfully but did not start:
MongoDB Atlas rejected the published service because its IP was not on the
Atlas access list.
Configure the stable production secrets listed above before relying on stored
provider credentials or sessions.
