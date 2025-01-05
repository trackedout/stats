map({
    player: .player,
    phase1Wins: .phase1.competitive.wins,
    phase1Games: .phase1.competitive.total,
    phase2Wins: .phase2.competitive.wins,
    phase2Games: .phase2.competitive.total,
    compWins: (.phase1.competitive.wins + .phase2.competitive.wins),
    compGames: (.phase1.competitive.total + .phase2.competitive.total),
  })
| {
    totalPhase1Wins: map(.phase1Wins) | add,
    totalPhase1Games: map(.phase1Games) | add,
    totalPhase2Wins: map(.phase2Wins) | add,
    totalPhase2Games: map(.phase2Games) | add,
    totalWins: map(.compWins) | add,
    totalGames: map(.compGames) | add
  } | .totalWins as $totalWins | .totalGames as $totalGames
  | {
    phase1: {
        totalWins: .totalPhase1Wins,
        totalGames: .totalPhase1Games,
        winRate: ((.totalPhase1Wins / .totalPhase1Games) * 100),
    },
    phase2: {
        totalWins: .totalPhase2Wins,
        totalGames: .totalPhase2Games,
        winRate: ((.totalPhase2Wins / .totalPhase2Games) * 100),
    },
    overall: {
        totalWins: $totalWins,
        totalGames: $totalGames,
        winRate: (($totalWins / $totalGames) * 100)
    }
  }
