## Adding another phase

1. Edit `./createPhaseStats.js` and:
   1. Add a new method call in the `main()` function to create the collection for the new phase
   2. Update the end date for the `playerStatsAllPhases` collection
   3. Update the dates in `saveTradeLogToDisk`
2. Edit `./join-stats.sh` and:
   1. Add the new phase to the array
   2. Add the new phase document at the end (e.g. `./output/playerStatsPhaseX.json`)
3. Edit `./stats.jq` and:
   1. Associate the new phase document with its related phase global variable (around line 65)

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


## Stats site

1. Run `./generate-site-data.sh`
2. Edit `docs/index.html` and update `const phases = ...` (line 338)
3. In `docs/`, run `python3 -m http.server 8000` to test
