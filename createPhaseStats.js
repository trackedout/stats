import { MongoClient } from "mongodb";
import fs from "fs";

const uri = "mongodb://dunga-dunga:dunga-dunga@mongodb:27017/dunga-dunga";
const client = new MongoClient(uri);

async function createPhaseStats(startDate, endDate, outputCollection) {
    const db = client.db();

    // Drop the output collection if it exists
    const collections = await db.listCollections({ name: outputCollection }).toArray();
    if (collections.length > 0) {
        console.log(`Dropping collection ${outputCollection}`);
        await db.collection(outputCollection).drop();
    }

    console.log("Creating collection", outputCollection);
    await db.collection("events").aggregate([
        {
            $match: {
                server: { $regex: /d[0-9]{3}|lobby/ },
                createdAt: {
                    $gte: startDate,
                    $lt: endDate,
                },
                $or: [
                    { name: /game-(won|lost)/ },
                    { name: "trade-requested", "metadata.source-scoreboard": "competitive-do2.lifetime.escaped.tomes" },
                    { name: /difficulty-selected-.*/ },
                ]
            }
        },
        {
            $lookup: {
                from: "claims",
                localField: "metadata.run-id",
                foreignField: "metadata.run-id",
                as: "claimDetails"
            }
        },
        {
            $unwind: {
                path: "$claimDetails",
                preserveNullAndEmptyArrays: true
            }
        },
        {
            $group: {
                _id: "$player",
                totalPractice: {
                    $sum: {
                        $cond: [
                            { $eq: ["$claimDetails.metadata.run-type", "p"] }, 1, 0
                        ]
                    }
                },
                totalCompetitive: {
                    $sum: {
                        $cond: [
                            { $eq: ["$claimDetails.metadata.run-type", "c"] }, 1, 0
                        ]
                    }
                },
                totalPracticeWins: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "game-won"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "p"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalPracticeLosses: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "game-lost"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "p"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalCompetitiveWins: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "game-won"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "c"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalCompetitiveLosses: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "game-lost"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "c"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalTomes: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "trade-requested"] },
                                    { $eq: ["$metadata.source-scoreboard", "competitive-do2.lifetime.escaped.tomes"] }
                                ]
                            },
                            { $toInt: "$metadata.source-count" },
                            0
                        ]
                    }
                },
                totalEasyPractice: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-easy"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "p"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalMediumPractice: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-medium"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "p"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalHardPractice: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-hard"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "p"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalDeadlyPractice: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-deadly"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "p"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalDeepFrostPractice: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-deepfrost"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "p"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalEasyCompetitive: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-easy"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "c"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalMediumCompetitive: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-medium"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "c"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalHardCompetitive: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-hard"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "c"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalDeadlyCompetitive: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-deadly"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "c"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                },
                totalDeepFrostCompetitive: {
                    $sum: {
                        $cond: [
                            {
                                $and: [
                                    { $eq: ["$name", "difficulty-selected-deepfrost"] },
                                    { $eq: ["$claimDetails.metadata.run-type", "c"] }
                                ]
                            },
                            1,
                            0
                        ]
                    }
                }
            }
        },
        {
            $addFields: {
                totalPracticeRuns: { $add: ["$totalPracticeWins", "$totalPracticeLosses"] },
                totalCompetitiveRuns: { $add: ["$totalCompetitiveWins", "$totalCompetitiveLosses"] },
            }
        },
        {
            $addFields: {
                totalRuns: { $add: ["$totalPracticeRuns", "$totalCompetitiveRuns"] },
            }
        },
        {
            $project: {
                _id: 0,
                player: "$_id",
                stats: {
                    total: "$totalRuns",
                    practice: {
                        total: "$totalPracticeRuns",
                        easy: "$totalEasyPractice",
                        medium: "$totalMediumPractice",
                        hard: "$totalHardPractice",
                        deadly: "$totalDeadlyPractice",
                        deepFrost: "$totalDeepFrostPractice",
                        wins: "$totalPracticeWins",
                        losses: "$totalPracticeLosses"
                    },
                    competitive: {
                        total: "$totalCompetitiveRuns",
                        easy: "$totalEasyCompetitive",
                        medium: "$totalMediumCompetitive",
                        hard: "$totalHardCompetitive",
                        deadly: "$totalDeadlyCompetitive",
                        deepFrost: "$totalDeepFrostCompetitive",
                        wins: "$totalCompetitiveWins",
                        losses: "$totalCompetitiveLosses"
                    },
                    tomesSubmitted: "$totalTomes"
                }
            }
        },
        {
            $out: outputCollection
        }
    ]).toArray();
}

async function main() {
    try {
        await client.connect();

        // Use console arg to determine whether to run these
        if (process.argv.length > 2 && process.argv[2] === "--create-collections") {
            await createPhaseStats(new Date("2024-12-07T16:00:00.000Z"), new Date("2025-02-01T15:00:00.000Z"), "playerStatsAllPhases"); // End date should be end of latest phase
            await createPhaseStats(new Date("2024-12-07T16:00:00.000Z"), new Date("2024-12-21T15:00:00.000Z"), "playerStatsPhase1");
            await createPhaseStats(new Date("2024-12-21T16:00:00.000Z"), new Date("2025-01-04T15:00:00.000Z"), "playerStatsPhase2");
            await createPhaseStats(new Date("2025-01-04T16:00:00.000Z"), new Date("2025-01-18T15:00:00.000Z"), "playerStatsPhase3");
            await createPhaseStats(new Date("2025-01-18T16:00:00.000Z"), new Date("2025-02-01T15:00:00.000Z"), "playerStatsPhase4");
        }

        await writePlayerStatsToDisk();
        await saveScoresToDisk();
        await saveEmbersToDisk();
        await saveTradeLogToDisk();

        console.log("Phase stats collections created successfully");
    } catch (error) {
        console.error("Error creating phase stats:", error);
    } finally {
        // Ensure the client will close when you finish or encounter an error
        await client.close();
    }
}

async function saveScoresToDisk() {
    const db = client.db();
    const scores = await db.collection("scores").find(
        { key: "do2.inventory.shards.competitive" },
        { _id: 0, player: 1, key: 1, value: 1 }
    ).sort({ value: 1 }).toArray();

    fs.writeFileSync("output/compShardsAllPlayers.json", JSON.stringify(scores, null, 4));
    console.log(`Wrote ${scores.length} competitive shard scores to disk`);
}

async function saveEmbersToDisk() {
    const db = client.db();
    const scores = await db.collection("scores").find(
        { key: "competitive-do2.lifetime.escaped.embers" },
        { _id: 0, player: 1, key: 1, value: 1 }
    ).sort({ value: 1 }).toArray();

    fs.writeFileSync("output/compEmbersAllPlayers.json", JSON.stringify(scores, null, 4));
    console.log(`Wrote ${scores.length} competitive escaped ember scores to disk`);
}

async function saveTradeLogToDisk() {
    const db = client.db();
    // db.events.find({ name: 'trade-requested', 'metadata.target-scoreboard': 'do2.inventory.shards.competitive' }, { _id: 0, name: 1, player: 1, metadata: 1 }).sort({ createdAt: -1 }).toArray()
    var trades = await db.collection("events").find(
        {
            name: "trade-requested",
            $or: [
                { "metadata.target-scoreboard": "do2.inventory.shards.competitive" },
                { "metadata.source-scoreboard": "competitive-do2.lifetime.escaped.tomes" }
            ],
            createdAt: {
                $gte: new Date("2024-12-07T16:00:00.000Z"),
            }
        },
        { _id: 0, name: 1, player: 1, metadata: 1, createdAt: 1 }
    ).sort({ createdAt: -1 }).toArray();

    trades = trades.map(trade => {
        var phase = -1;
        if (trade.createdAt >= new Date("2024-12-07T16:00:00.000Z") && trade.createdAt < new Date("2024-12-21T15:00:00.000Z")) {
            phase = 1;
        } else if (trade.createdAt < new Date("2025-01-04T15:00:00.000Z")) {
            phase = 2;
        } else if (trade.createdAt < new Date("2025-01-18T15:00:00.000Z")) {
            phase = 3;
        } else if (trade.createdAt < new Date("2025-02-01T15:00:00.000Z")) {
            phase = 4;
        }

        if (phase === -1) {
            console.log("Invalid phase", trade);
        }

        return {
            ...trade,
            phase,
        }
    });

    fs.writeFileSync("output/compShardsTradeLog.json", JSON.stringify(trades, null, 4));
    console.log(`Wrote ${trades.length} trade logs to disk`);
}

async function writePlayerStatsToDisk() {
    const db = client.db();
    const collections = await db.listCollections().toArray();
    for (const collection of collections) {
        const collectionName = collection.name;
        if (collectionName.startsWith("playerStats")) {
            await writeCollectionToDisk(db, collectionName);
        }
    }
}

main();

async function writeCollectionToDisk(db, collectionName) {
    const stats = await db.collection(collectionName).find().toArray();
    fs.writeFileSync(`output/${collectionName}.json`, JSON.stringify(stats, null, 2));
    console.log(`Wrote ${stats.length} ${collectionName} stats to disk`);
}
