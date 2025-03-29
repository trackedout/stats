import { MongoClient } from 'mongodb';
import fs from 'fs';

const uri = "mongodb://dunga-dunga:dunga-dunga@mongodb:27017/dunga-dunga";
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

const pointsForPosition = [25, 21, 18, 16, 14, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
const phases = [1, 2, 3, 4, 5, 6, 7];

const getLeaderboard = async () => {
  try {
    await client.connect();
    const db = client.db('dunga-dunga');
    const playerStats = {};

    for (const phase of phases) {
      const collection = db.collection(`playerStatsPhase${phase}`);
      const players = await collection.find({ "stats.tomesSubmitted": { $gt: 0 } }).toArray();

      players.sort((a, b) => b.stats.tomesSubmitted - a.stats.tomesSubmitted);

      let currentPoints = 0;
      let currentRank = 0;
      let tomesLastRank = null;

      players.forEach((player) => {
        if (!playerStats[player.player]) {
          playerStats[player.player] = { totalPoints: 0, totalTomes: 0, stats: {} };
        }

        if (player.stats.tomesSubmitted !== tomesLastRank) {
          currentPoints = pointsForPosition[currentRank] || 0;
          tomesLastRank = player.stats.tomesSubmitted;
          currentRank++;
        }

        playerStats[player.player].stats[phase] = {
          tomesSubmitted: player.stats.tomesSubmitted,
          points: currentPoints
        };
        playerStats[player.player].totalPoints += currentPoints;
        playerStats[player.player].totalTomes += player.stats.tomesSubmitted;
      });
    }

    const leaderboard = Object.keys(playerStats)
      .map(player => ({ player, ...playerStats[player] }))
      .sort((a, b) => b.totalPoints - a.totalPoints);

    let currentRank = 0;
    let lastTotalPoints = null;

    leaderboard.forEach((entry) => {
      if (entry.totalPoints !== lastTotalPoints) {
        currentRank++;
        lastTotalPoints = entry.totalPoints;
      }
      entry.rank = currentRank;
    });

    const csvData = leaderboard.map(entry => {
      const stats = phases.map(phase => entry.stats[phase] ? `${entry.stats[phase].tomesSubmitted},${entry.stats[phase].points}` : '0,0').join(',');
      return `${entry.rank},${entry.player},${entry.totalPoints},${entry.totalTomes},${stats}`;
    });

    const header = `Rank,Player,Total Points,Total Tomes,${phases.map(phase => `Phase ${phase} Tomes,Phase ${phase} Points`).join(',')}`;
    const csvOutput = [header, ...csvData].join('\n');

    fs.writeFileSync('leaderboard.csv', csvOutput);
    console.log('CSV file has been saved as leaderboard.csv');
  } finally {
    await client.close();
  }
};

getLeaderboard().catch(console.error);