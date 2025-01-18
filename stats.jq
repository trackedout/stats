# compShardsTradeLog.json looks like:
# [
    # {
    #     "_id": "677928ca9e009a0c33d44412",
    #     "name": "trade-requested",
    #     "player": "mrfireflyer",
    #     "count": 1,
    #     "server": "lobby",
    #     "x": 0,
    #     "y": 0,
    #     "z": 0,
    #     "sourceIP": "10.150.0.12",
    #     "metadata": {
    #         "run-type": "competitive",
    #         "source-scoreboard": "",
    #         "source-inversion-scoreboard": "",
    #         "source-count": "0",
    #         "target-scoreboard": "do2.inventory.shards.competitive",
    #         "target-count": "1",
    #         "reason": "Granted by jaek95 - Premature vex spwned in 3 instances"
    #     },
    #     "processingFailed": false,
    #     "createdAt": "2025-01-04T12:25:46.759Z",
    #     "updatedAt": "2025-01-04T12:25:46.759Z",
    #     "__v": 0
    # },
# ]

# playerStatsPhase1.json looks like:
# [
#   {
#     "_id": "6779af7b228de5085ba9f56d",
#     "player": "FrustratedCPU",
#     "stats": {
#       "total": 19,
#       "practice": {
#         "total": 7,
#         "easy": 1,
#         "medium": 6,
#         "hard": 0,
#         "deadly": 0,
#         "deepFrost": 0,
#         "wins": 5,
#         "losses": 2
#       },
#       "competitive": {
#         "total": 12,
#         "easy": 7,
#         "medium": 5,
#         "hard": 0,
#         "deadly": 0,
#         "deepFrost": 0,
#         "wins": 5,
#         "losses": 7
#       },
#       "tomesSubmitted": 0
#     }
#  }
# ]

(.[0] | map(tostring)) as $phases
| (.[4] | map({ key: .player, value: . }) | from_entries) as $p1   # playerStatsPhase1.json
| (.[5] | map({ key: .player, value: . }) | from_entries) as $p2   # playerStatsPhase2.json
| (.[6] | map({ key: .player, value: . }) | from_entries) as $p3   # playerStatsPhase3.json
| ({
  "1": $p1,
  "2": $p2,
  "3": $p3
}) as $phaseStats
| (
  .[1]  # compShardsTradeLog.json
  | group_by(.player)
  | map(.[0].player as $player | . as $trades | {
      (.[0].player): {
        trades: ($trades | map(.metadata + { createdAt, phase }) | sort_by(.createdAt)),

        phaseData: (reduce $phases[] as $phase ({}; .[$phase] = {

          shardsAddedByOperator: (($trades | map(select((.metadata["source-count"] == "0") and (.phase == ($phase | tonumber))) | .metadata["target-count"] | tonumber) | add) // 0),
          shardsAddedForPhase: (($trades | map(select((.metadata["reason"] // "") | contains("Phase")) | select(.phase == ($phase | tonumber)) | .metadata["target-count"] | tonumber) | add) // 0),

          shardsBought: (($trades | map(select(.phase == ($phase | tonumber) and .metadata["source-count"] != "0") | .metadata["target-count"] | tonumber) | add) // 0),

          tomesSubmitted: (($trades | map(select((.phase == ($phase | tonumber)) and (.metadata["source-scoreboard"] == "competitive-do2.lifetime.escaped.tomes") ) | .metadata["source-count"] | tonumber) | add) // 0)
        })),

        totalShardsAddedByOperator: (($trades | map(select(.metadata["source-count"] == "0") | .metadata["target-count"] | tonumber) | add) // 0),
        totalShardsBought: (($trades | map(select(.metadata["source-count"] != "0") | .metadata["target-count"] | tonumber) | add) // 0),
      }
    })
  | add) as $tradeLogs
| (.[2] | map({ key: .player, value: .value }) | from_entries) as $allPlayers   # compShardsAllPlayers.json
| (.[3] | map({ key: .player, value: .value }) | from_entries) as $emberScores  # compEmbersAllPlayers.json
| ($allPlayers | keys | unique) as $players
| $players | map(. as $player | {
    player: $player,
    tradeLog: ($tradeLogs[$player] // {}),
    phases: (reduce $phases[] as $phase ({}; ($phaseStats[$phase][$player]?.stats) as $playerPhaseStats | .[$phase] = $playerPhaseStats + {
      compRuns: ($playerPhaseStats.competitive?.total // 0),
      pracRuns: ($playerPhaseStats.practice?.total // 0),
      totalRuns: (($playerPhaseStats.competitive?.total // 0) + ($playerPhaseStats.practice?.total // 0)),
      tomesSubmitted: ($tradeLogs[$player].phaseData[$phase]?.tomesSubmitted // 0),
      shardsRefunded: (($tradeLogs[$player].phaseData[$phase]?.shardsAddedByOperator // 0) - ($tradeLogs[$player].phaseData[$phase]?.shardsAddedForPhase // 0)),
      shardsAddedForPhase: ($tradeLogs[$player].phaseData[$phase]?.shardsAddedForPhase // 0),
      shardsBought: ($tradeLogs[$player].shardsBought[$phase] // 0),
      compWinRate: (if ($playerPhaseStats.competitive?.wins > 0) then (($playerPhaseStats.competitive?.wins // 0) / ($playerPhaseStats.competitive?.total // 1)) else 0 end)
    })),
    totalPracRuns: 0, # just for field ordering
    totalCompRuns: 0, # just for field ordering
    totalRunsAllModes: 0, # just for field ordering
    totalEscapedEmbers: ($emberScores[$player] // 0),
  } | del(.stats, ._id))
| map(. + {
    totalRunsAllModes: (reduce .phases[] as $phase (0; . + $phase.totalRuns)),
    totalPracRuns: (reduce .phases[] as $phase (0; . + $phase.pracRuns)),
    totalCompRuns: (reduce .phases[] as $phase (0; . + $phase.compRuns)),
    remainingShards: ($allPlayers[.player]),
  })
| map(. + {
    totalShardsBought: (.tradeLog.totalShardsBought // 0),
    totalShardsWithoutRuns: (.remainingShards + .totalCompRuns),
    tradeLog: (.tradeLog + {
      shardsRefunded: (reduce .phases[] as $phase (0; . + $phase.shardsRefunded)),
    }),
  })
| map(. + {
    totalShardsAddedByOperator: (reduce .phases[] as $phase (0; . + $phase.shardsAddedForPhase)),
  })
| map(. + {
    shardsExcludingTrades: (.totalShardsWithoutRuns - .totalShardsBought - .totalShardsAddedByOperator)
  })

# At this point the output looks like:
# [
#   {
#     "player": "4Ply",
#     "phase1CompRuns": 3,
#     "phase2CompRuns": 4,
#     "phase1PracRuns": 3,
#     "phase2PracRuns": 1,
#     "totalCompRuns": 7,
#     "remainingShards": 22,
#     "tomesSubmittedPhase1": 0,
#     "tomesSubmittedPhase2": 0,
#     "phase1RunsAllModes": 6,
#     "phase2RunsAllModes": 5,
#     "totalRunsAllModes": 11,
#     "shardsBought": 0,
#     "shardsAddedByOperator": 0,
#     "shardsAddedForPhase": 17,
#     "shardsWithoutRuns": 29,
#     "shardsForPhase": 29
#   }
# ]

| map(
  .potentialEmberValue =
    if .totalCompRuns == 0 then
      0
    else
      # Calculate the base value first
      (.totalEscapedEmbers + ((.totalEscapedEmbers / .totalCompRuns) * .remainingShards))
    end
)

| . as $allPlayerData
# Get all potential ember values for active players
# Find the min potential ember value cutoff using:
# > ./join-stats.sh | jq 'map({ player, remainingShards, totalCompRuns, totalEscapedEmbers, potentialEmberValue, shardsToAllocatePreCap, shardsToAllocate } | select(.remainingShards == 0 and .potentialEmberValue > 0)) | sort_by(.potentialEmberValue) | reverse'
| map(select(.totalCompRuns > 0 and .potentialEmberValue > 233) | .potentialEmberValue) as $allPlayerEmberValues
| $allPlayerData

# Calculate ember allocations using =ROUND(17-(E{player}-MIN(E:E))/(MAX(E:E)-MIN(E:E))*8), where E is potentialEmberValue
| map(
  .shardsToAllocatePreCap = if (.totalCompRuns == 0) then
    0
  else
    (17 - (.potentialEmberValue - ($allPlayerEmberValues | min)) / (($allPlayerEmberValues | max) - ($allPlayerEmberValues | min)) * 8)
  end
)
# Now cap the shards so that the player doesn't end up with more than 34 shards. formula is =MIN(34, remainingShards+shardsToAllocatePreCap)-remainingShards
| map(
  .shardsToAllocate = ((([34, ((.remainingShards + .shardsToAllocatePreCap))] | min) - .remainingShards) | round)
)

| map(del(.shardsAddedByOperator, .shardsAddedForPhase, .shardsWithoutRuns))
| map(del(.tradeLog.phaseData))
