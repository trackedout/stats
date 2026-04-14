#!/bin/bash

phases=$(jq -c 'map(select(.state == "COMPLETED") | .phase)' phases.json)

phase_files=()
for p in $(echo "$phases" | jq -r '.[]'); do
  phase_files+=("./output/playerStatsPhase${p}.json")
done

jq -s -f stats.jq \
  <(echo "$phases") \
  ./output/compShardsTradeLog.json \
  ./output/compShardsAllPlayers.json \
  ./output/compEmbersAllPlayers.json \
  "${phase_files[@]}"
