import Foundation

enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
}

enum ActivityType: String, Codable {
    case relicHunt
    case puzzleDoor
    case tribalTrail
}

struct Level: Identifiable, Hashable, Codable {
    let id: Int
    let title: String
    let difficulty: Difficulty
    let activity: ActivityType
}

struct ActivityResult {
    let levelID: Int
    let stars: Int
    let timeTaken: TimeInterval
    let hintsUsed: Int
    let choicesMade: Int
}

enum Achievements {
    static let firstQuest = "First Quest Completed"
    static let allEasy = "Easy Explorer"
    static let allNormal = "Jungle Strategist"
    static let allHard = "Relic Master"
    static let perfectTen = "Ten Perfect Runs"
}
