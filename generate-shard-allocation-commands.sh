#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <phase-number>"
  exit 1
fi

./join-stats.sh | jq 'map({ player, remainingShards, totalCompRuns, totalEscapedEmbers, potentialEmberValue, shardsToAllocatePreCap, shardsToAllocate } | select((.shardsToAllocate) > 0)) | sort_by(.potentialEmberValue) | reverse | map(
  "just exec lobby rcon-cli do give-item \(.player) competitive SHARD \(.shardsToAllocate) Phase '${1}' start"
)[]' -r
