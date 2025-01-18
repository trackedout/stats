#!/bin/bash

jq -s -f stats.jq ./output/playerStatsPhase1.json ./output/playerStatsPhase2.json ./output/compShardsTradeLog.json ./output/compShardsAllPlayers.json ./output/compEmbersAllPlayers.json
