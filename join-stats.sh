#!/bin/bash

jq -s -f stats.jq <(echo '[1, 2, 3, 4, 5, 6]') \
    ./output/compShardsTradeLog.json \
    ./output/compShardsAllPlayers.json \
    ./output/compEmbersAllPlayers.json \
    ./output/playerStatsPhase1.json \
    ./output/playerStatsPhase2.json \
    ./output/playerStatsPhase3.json \
    ./output/playerStatsPhase4.json \
    ./output/playerStatsPhase5.json \
    ./output/playerStatsPhase6.json
