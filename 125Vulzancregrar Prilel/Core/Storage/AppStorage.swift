//
//  AppStorage.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import Foundation
import Combine

extension Notification.Name {
    static let appStorageDidReset = Notification.Name("appStorageDidReset")
}

struct RewardOutcome {
    let achievementsUnlocked: [String]
    let xpGained: Int
    let streak: Int
    let loreFragmentsUnlocked: Int
}

final class AppStorage: ObservableObject {
    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }
    @Published private(set) var starsByLevel: [Int: Int]
    @Published private(set) var unlockedLevel: Int
    @Published private(set) var totalPlayTime: TimeInterval
    @Published private(set) var totalActivitiesPlayed: Int
    @Published private(set) var explorerXP: Int
    @Published private(set) var perfectStreak: Int
    @Published private(set) var bestPerfectStreak: Int
    @Published private(set) var loreFragments: Int
    @Published private(set) var claimedMilestones: Set<Int>

    let levels: [Level] = [
        Level(id: 1, title: "Relic Grove", difficulty: .easy, activity: .relicHunt),
        Level(id: 2, title: "Stone Rings", difficulty: .easy, activity: .puzzleDoor),
        Level(id: 3, title: "Trail Whispers", difficulty: .easy, activity: .tribalTrail),
        Level(id: 4, title: "Hidden Canopy", difficulty: .normal, activity: .relicHunt),
        Level(id: 5, title: "Gate of Echoes", difficulty: .normal, activity: .puzzleDoor),
        Level(id: 6, title: "Clan Crossroads", difficulty: .normal, activity: .tribalTrail),
        Level(id: 7, title: "Sunken Shrine", difficulty: .hard, activity: .relicHunt),
        Level(id: 8, title: "Titan Door", difficulty: .hard, activity: .puzzleDoor),
        Level(id: 9, title: "Final Trail", difficulty: .hard, activity: .tribalTrail),
        Level(id: 10, title: "Moss Vault", difficulty: .easy, activity: .relicHunt),
        Level(id: 11, title: "Rune Gate", difficulty: .easy, activity: .puzzleDoor),
        Level(id: 12, title: "River Oath", difficulty: .easy, activity: .tribalTrail),
        Level(id: 13, title: "Vine Labyrinth", difficulty: .normal, activity: .relicHunt),
        Level(id: 14, title: "Obsidian Rings", difficulty: .normal, activity: .puzzleDoor),
        Level(id: 15, title: "Moon Path", difficulty: .normal, activity: .tribalTrail),
        Level(id: 16, title: "Echo Temple", difficulty: .hard, activity: .relicHunt),
        Level(id: 17, title: "Guardian Seal", difficulty: .hard, activity: .puzzleDoor),
        Level(id: 18, title: "Last Covenant", difficulty: .hard, activity: .tribalTrail)
    ]

    private let defaults: UserDefaults

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let starsByLevel = "starsByLevel"
        static let unlockedLevel = "unlockedLevel"
        static let totalPlayTime = "totalPlayTime"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let explorerXP = "explorerXP"
        static let perfectStreak = "perfectStreak"
        static let bestPerfectStreak = "bestPerfectStreak"
        static let loreFragments = "loreFragments"
        static let claimedMilestones = "claimedMilestones"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        self.unlockedLevel = max(1, defaults.integer(forKey: Keys.unlockedLevel))
        self.totalPlayTime = defaults.double(forKey: Keys.totalPlayTime)
        self.totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        self.explorerXP = defaults.integer(forKey: Keys.explorerXP)
        self.perfectStreak = defaults.integer(forKey: Keys.perfectStreak)
        self.bestPerfectStreak = defaults.integer(forKey: Keys.bestPerfectStreak)
        self.loreFragments = defaults.integer(forKey: Keys.loreFragments)
        self.claimedMilestones = Set(defaults.array(forKey: Keys.claimedMilestones) as? [Int] ?? [])

        if let saved = defaults.dictionary(forKey: Keys.starsByLevel) as? [String: Int] {
            self.starsByLevel = Dictionary(uniqueKeysWithValues: saved.compactMap { key, value in
                guard let intKey = Int(key) else { return nil }
                return (intKey, value)
            })
        } else {
            self.starsByLevel = [:]
        }
    }

    var completedLevels: [Level] {
        levels.filter { starsByLevel[$0.id, default: 0] > 0 }
    }

    var totalStars: Int {
        starsByLevel.values.reduce(0, +)
    }

    var totalPossibleStars: Int {
        levels.count * 3
    }

    var achievements: [String] {
        var list: [String] = []
        if !completedLevels.isEmpty { list.append(Achievements.firstQuest) }
        if levels.filter({ $0.difficulty == .easy }).allSatisfy({ starsByLevel[$0.id, default: 0] > 0 }) { list.append(Achievements.allEasy) }
        if levels.filter({ $0.difficulty == .normal }).allSatisfy({ starsByLevel[$0.id, default: 0] > 0 }) { list.append(Achievements.allNormal) }
        if levels.filter({ $0.difficulty == .hard }).allSatisfy({ starsByLevel[$0.id, default: 0] > 0 }) { list.append(Achievements.allHard) }
        if starsByLevel.values.filter({ $0 == 3 }).count >= 10 { list.append(Achievements.perfectTen) }
        return list
    }

    var explorerRank: String {
        switch explorerXP {
        case 0..<300: return "Trail Scout"
        case 300..<800: return "Relic Tracker"
        case 800..<1500: return "Jungle Pathfinder"
        default: return "Ancient Vanguard"
        }
    }

    var nextRankXP: Int {
        switch explorerXP {
        case 0..<300: return 300
        case 300..<800: return 800
        case 800..<1500: return 1500
        default: return explorerXP
        }
    }

    func isUnlocked(_ level: Level) -> Bool {
        level.id <= unlockedLevel
    }

    func stars(for levelID: Int) -> Int {
        starsByLevel[levelID, default: 0]
    }

    func apply(result: ActivityResult) -> RewardOutcome {
        let before = Set(achievements)
        starsByLevel[result.levelID] = max(starsByLevel[result.levelID, default: 0], result.stars)
        totalPlayTime += result.timeTaken
        totalActivitiesPlayed += 1
        unlockedLevel = min(levels.count, max(unlockedLevel, result.levelID + 1))

        var gainedXP = (result.stars * 40) + (result.hintsUsed == 0 ? 20 : 0)
        if result.timeTaken < 35 { gainedXP += 20 }

        var streakFragments = 0
        if result.stars == 3 {
            perfectStreak += 1
            bestPerfectStreak = max(bestPerfectStreak, perfectStreak)
            if perfectStreak == 3 || perfectStreak == 5 {
                loreFragments += 1
                streakFragments = 1
                gainedXP += 50
            }
        } else {
            perfectStreak = 0
        }

        let starMilestones = [12, 24, 36, 48, totalPossibleStars]
        var milestoneFragments = 0
        for milestone in starMilestones where totalStars >= milestone && !claimedMilestones.contains(milestone) {
            claimedMilestones.insert(milestone)
            milestoneFragments += 1
        }
        loreFragments += milestoneFragments
        explorerXP += gainedXP

        persist()
        let after = Set(achievements)
        return RewardOutcome(
            achievementsUnlocked: Array(after.subtracting(before)).sorted(),
            xpGained: gainedXP,
            streak: perfectStreak,
            loreFragmentsUnlocked: milestoneFragments + streakFragments
        )
    }

    func resetAll() {
        hasSeenOnboarding = false
        starsByLevel = [:]
        unlockedLevel = 1
        totalPlayTime = 0
        totalActivitiesPlayed = 0
        explorerXP = 0
        perfectStreak = 0
        bestPerfectStreak = 0
        loreFragments = 0
        claimedMilestones = []
        defaults.removeObject(forKey: Keys.starsByLevel)
        defaults.removeObject(forKey: Keys.unlockedLevel)
        defaults.removeObject(forKey: Keys.totalPlayTime)
        defaults.removeObject(forKey: Keys.totalActivitiesPlayed)
        defaults.removeObject(forKey: Keys.explorerXP)
        defaults.removeObject(forKey: Keys.perfectStreak)
        defaults.removeObject(forKey: Keys.bestPerfectStreak)
        defaults.removeObject(forKey: Keys.loreFragments)
        defaults.removeObject(forKey: Keys.claimedMilestones)
        defaults.set(false, forKey: Keys.hasSeenOnboarding)
        NotificationCenter.default.post(name: .appStorageDidReset, object: nil)
    }

    func format(time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: time) ?? "0m 00s"
    }

    private func persist() {
        let serializable = Dictionary(uniqueKeysWithValues: starsByLevel.map { (String($0.key), $0.value) })
        defaults.set(serializable, forKey: Keys.starsByLevel)
        defaults.set(unlockedLevel, forKey: Keys.unlockedLevel)
        defaults.set(totalPlayTime, forKey: Keys.totalPlayTime)
        defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed)
        defaults.set(explorerXP, forKey: Keys.explorerXP)
        defaults.set(perfectStreak, forKey: Keys.perfectStreak)
        defaults.set(bestPerfectStreak, forKey: Keys.bestPerfectStreak)
        defaults.set(loreFragments, forKey: Keys.loreFragments)
        defaults.set(Array(claimedMilestones).sorted(), forKey: Keys.claimedMilestones)
    }
}
