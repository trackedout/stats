#!/bin/bash

./join-stats.sh | jq --arg phase "${1}" 'map({ player, tomes: .phases[$phase]?.tomesSubmitted }) | map(select(.tomes > 0)) | sort_by(.tomes) | reverse | map("1. \(.player) - \(.tomes) tomes")[]' -r
