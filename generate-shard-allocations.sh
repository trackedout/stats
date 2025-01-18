#!/bin/bash

./join-stats.sh | jq 'map({ player, remainingShards, totalCompRuns, totalEscapedEmbers, potentialEmberValue, shardsToAllocatePreCap, shardsToAllocate } | select((.shardsToAllocate) > 0)) | sort_by(.potentialEmberValue) | reverse' | jq-csv
