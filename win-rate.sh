#!/bin/bash

./join-stats.sh | jq -f win-rate.jq
