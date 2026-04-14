#!/bin/bash

set -euo pipefail

./join-stats.sh | jq -f clean-data-for-site.jq >./docs/data/stats.json
echo "Data written to ./docs/data/stats.json"

jq 'map(select(.state == "COMPLETED"))' phases.json >./docs/data/phases.json
echo "Phases written to ./docs/data/phases.json"
