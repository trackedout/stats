#!/bin/bash

./join-stats.sh | jq 'map({ player, remainingShards, totalCompRuns, totalEscapedEmbers, potentialEmberValue, shardsToAllocatePreCap, shardsToAllocate } | select((.shardsToAllocate) > 0)) | sort_by(.potentialEmberValue) | reverse | map(
  "just exec lobby rcon-cli do give-item \(.player) COMPETITIVE SHARD \(.shardsToAllocate) Phase 5 start"
)[]' -r
