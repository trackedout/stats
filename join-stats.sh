#!/bin/bash

jq -s -f stats.jq <(echo '[1, 2, 3]') ./output/compShardsTradeLog.json ./output/compShardsAllPlayers.json ./output/compEmbersAllPlayers.json ./output/playerStatsPhase1.json ./output/playerStatsPhase2.json ./output/playerStatsPhase3.json
