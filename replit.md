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

## Current setup limitation

Dependency installation has not succeeded: Replit's package service returned
HTTP 404 for `npm-run-path` tarballs (versions 4.0.1 and 5.3.0), including an
attempt using the latest parent Jest package. No dependency upgrades were saved.
Do not bypass the package firewall or broadly replace the project's tooling.
The workflow is configured but not started until dependencies and MongoDB are
available. A frontend build, HTTP checks and browser verification remain required.
