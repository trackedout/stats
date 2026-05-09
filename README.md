## Adding another phase

The related scripts (`createPhaseStats.js`, `join-stats.sh`, `stats.jq`, the site) will read from `phases.json`.

1. Append a new entry to `phases.json`:
```json
{ "phase": 3, "state": "ACTIVE", "start": "2026-04-14T06:00:00Z", "end": "2026-04-26T21:00:00Z" },
```
2. Then set completed phases to "COMPLETED"

## Running

Set up port forward:
```bash
cd davybones

export KUBECONTEXT=ash
just mongo-port-forward
```

Generate stats:
```bash
rm output/*.json && node createPhaseStats.js --create-collections
```

## Updating lobby leaderboard + join message

```bash
cd davybones

export KUBECONTEXT=ash
just api-port-forward # API
just update-phase-configs
```

## Stats site

1. Run `./generate-site-data.sh`
2. In `docs/`, run `python3 -m http.server 8000` to test

