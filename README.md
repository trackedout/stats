## Adding another phase

1. Edit `./createPhaseStats.js` and:
   1. Add a new method call in the `main()` function to create the collection for the new phase
   2. Update the end date for the `playerStatsAllPhases` collection
2. Edit `./join-stats.sh` and:
   1. Add the new phase to the array
   2. Add the new phase document at the end (e.g. `./output/playerStatsPhaseX.json`)
3. Edit `./stats.jq` and:
   1. Associate the new phase document with its related phase global variable (around line 65)
