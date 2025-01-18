map(del(
  .tradeLog,
  # Delete all shard data
  .phase1.shardsAddedByOperator,
  .phase1.shardsAddedForPhase,
  .phase1.shardsRefunded,
  .phase1.shardsBought,
  .phase2.shardsAddedByOperator,
  .phase2.shardsAddedForPhase,
  .phase2.shardsRefunded,
  .phase2.shardsBought,
  .totalShardsWithoutRuns,
  .totalShardsBought,
  .totalShardsAddedByOperator,
  .remainingShards,
  .shardsExcludingTrades,
  .totalLifetimeEmbers
))
