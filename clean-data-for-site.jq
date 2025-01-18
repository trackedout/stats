map(del(
  .tradeLog,
  .totalShardsWithoutRuns,
  .totalShardsBought,
  .totalShardsAddedByOperator,
  .remainingShards,
  .shardsExcludingTrades,
  .totalEscapedEmbers,
  .potentialEmberValue
))

# Delete all shard data
| map(.phases |= map(del(
  .shardsAddedByOperator,
  .shardsAddedForPhase,
  .shardsRefunded,
  .shardsBought
)))
| map(del(
  .shardsToAllocatePreCap,
  .shardsToAllocate
))
