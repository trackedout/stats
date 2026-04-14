#!/bin/bash

(
  echo "Name,P1,P2,Total Runs"

  jq -r '
  map(select(.totalCompRuns > 0))
  | sort_by((.phases | map(select(.compRuns > 0) | .compWinRate) | add / length) * -1)[]
    # Show player and win rate for each phase (but just "-" if they did not run that phase)
  | [ .player, (.phases | map(if .compRuns == 0 then "-" else "\(.compWinRate*100 | round)%" end))[], .totalCompRuns ]
  | @csv' docs/data/stats.json | tr -d '"'
) | column -t -s ','
