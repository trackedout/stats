#!/bin/bash

set -euo pipefail

./join-stats.sh | jq -f clean-data-for-site.jq >./docs/data/stats.json
echo "Data written to ./docs/data/stats.json"
