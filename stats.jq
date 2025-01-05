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

(.[0] | map({ key: .player, value: . }) | from_entries) as $p1     # playerStatsPhase1.json
| (.[1] | map({ key: .player, value: . }) | from_entries) as $p2   # playerStatsPhase2.json
| (
  .[2]  # compShardsTradeLog.json
  | group_by(.player)
  | map(.[0].player as $player | {
      (.[0].player): {
        trades: map(.metadata + { createdAt }) | sort_by(.createdAt),
        totalShardsRefunded: map(select(.metadata["source-count"] == "0") | .metadata["target-count"] | tonumber) | add,
        totalShardsAddedForPhase: map(select((.metadata["reason"] // "") | contains("Phase")) | .metadata["target-count"] | tonumber) | add,
        totalShardsBought: map(select(.metadata["source-count"] != "0") | .metadata["target-count"] | tonumber) | add,
        # convert createdAt to date and compare
        totalShardsBoughtPhase1: map(
            select(
                .createdAt != null and
                (.createdAt | if type == "string" then split(".")[0] | strptime("%Y-%m-%dT%H:%M:%S") | mktime else 0 end) as $createdAt
                | $createdAt > ("2024-12-07T16:00:00" | strptime("%Y-%m-%dT%H:%M:%S") | mktime) and
                $createdAt < ("2024-12-21T16:00:00" | strptime("%Y-%m-%dT%H:%M:%S") | mktime) and
                .metadata["source-count"] != "0"
            )
            | .metadata["target-count"] | tonumber
        ) | add,
        totalShardsBoughtPhase2: map(
            select(
                .createdAt != null and
                (.createdAt | if type == "string" then split(".")[0] | strptime("%Y-%m-%dT%H:%M:%S") | mktime else 0 end) as $createdAt
                | $createdAt >= ("2024-12-21T16:00:00" | strptime("%Y-%m-%dT%H:%M:%S") | mktime) and
                $createdAt < ("2025-01-04T15:00:00" | strptime("%Y-%m-%dT%H:%M:%S") | mktime) and
                .metadata["source-count"] != "0"
            )
            | .metadata["target-count"] | tonumber
        ) | add,
      }
    })
  | add) as $tradeLogs
| (.[3] | map({ key: .player, value: .value }) | from_entries) as $allPlayers   # compShardsAllPlayers.json
| ($allPlayers | keys | unique) as $players
| $players | map({
    player: .,
    phase1: ($p1[.]?.stats),
    phase2: ($p2[.]?.stats),
    phase1CompRuns: ($p1[.]?.stats?.competitive?.total // 0),
    phase2CompRuns: ($p2[.]?.stats?.competitive?.total // 0),
    phase1PracRuns: ($p1[.]?.stats?.practice?.total // 0),
    phase2PracRuns: ($p2[.]?.stats?.practice?.total // 0),
    totalCompRuns: 0, # just for field ordering
    remainingShards: ($allPlayers[.]),
    tomesSubmittedPhase1: ($p1[.]?.stats?.tomesSubmitted // 0),
    tomesSubmittedPhase2: ($p2[.]?.stats?.tomesSubmitted // 0), # WRONG! This is showing both phase data
  } | del(.stats, ._id))
| map(. + {
    phase1RunsAllModes: (.phase1CompRuns + .phase1PracRuns),
    phase2RunsAllModes: (.phase2CompRuns + .phase2PracRuns)
  })
| map(. + {
    totalRunsAllModes: (.phase1RunsAllModes + .phase2RunsAllModes)
  })
| map(. + {
    totalCompRuns: (.phase1CompRuns + .phase2CompRuns)
  })
| map(. + {
    tradeLog: ($tradeLogs[.player]),
    shardsBought: ($tradeLogs[.player].totalShardsBought // 0),
    shardsAddedByOperator: ($tradeLogs[.player].totalShardsRefunded // 0), # TODO: Filter by phase
    shardsAddedForPhase: ($tradeLogs[.player].totalShardsAddedForPhase // 0), # TODO: Filter by phase
    shardsWithoutRuns: (.remainingShards + .phase1CompRuns + .phase2CompRuns),
  })
| map(. + {
    shardsAddedByOperator: (.shardsAddedByOperator - .shardsAddedForPhase),
  })
| map(. + {
    shardsForPhase: (.shardsWithoutRuns - .shardsBought - .shardsAddedByOperator)
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

# Now group phase specific data into sub-objects
| map({
    player: .player,
    phase1: (.phase1 + {
      compRuns: .phase1CompRuns,
      pracRuns: .phase1PracRuns,
      totalRuns: .phase1RunsAllModes,
      tomesSubmitted: .tomesSubmittedPhase1,
      shardsAddedByOperator: .shardsAddedByOperator,
      shardsAddedForPhase: .shardsAddedForPhase,
      shardsWithoutRuns: .shardsWithoutRuns,
      shardsBought: (.tradeLog.totalShardsBoughtPhase1 // 0),
      compWinRate: (if .phase1.competitive.wins > 0 then ((.phase1.competitive.wins // 0) / (.phase1.competitive.total // 1)) else 0 end),
    }),
    phase2: (.phase2 + {
      compRuns: .phase2CompRuns,
      pracRuns: .phase2PracRuns,
      totalRuns: .phase2RunsAllModes,
      tomesSubmitted: .tomesSubmittedPhase2,
      shardsAddedByOperator: .shardsAddedByOperator,
      shardsAddedForPhase: .shardsAddedForPhase,
      shardsWithoutRuns: .shardsWithoutRuns,
      shardsBought: (.tradeLog.totalShardsBoughtPhase2 // 0),
      compWinRate: (if .phase2.competitive.wins > 0 then ((.phase2.competitive.wins // 0) / (.phase2.competitive.total // 1)) else 0 end),
    }),
    tradeLog: .tradeLog,
  })
| map(del(.tradeLog.trades))
