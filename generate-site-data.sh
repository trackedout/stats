#!/bin/bash

set -euo pipefail

./join-stats.sh | jq -f clean-data-for-site.jq >./site/data/stats.json
echo "Data written to ./site/data/stats.json"
