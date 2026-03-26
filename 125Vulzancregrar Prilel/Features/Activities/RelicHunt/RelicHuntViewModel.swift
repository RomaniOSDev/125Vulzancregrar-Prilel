import Foundation
import Combine

final class RelicHuntViewModel: ObservableObject {
    struct Tile: Identifiable {
        let id = UUID()
        let isRelic: Bool
        var isRevealed: Bool = false
    }

    @Published var tiles: [Tile] = []
    @Published var timeLeft: Int = 0
    @Published var hintsUsed: Int = 0
    @Published var showResult = false
    @Published var lastResult: ActivityResult?

    private var startTime: Date = Date()
    private var timer: Timer?
    private let level: Level
    private let relicCount: Int

    init(level: Level) {
        self.level = level
        self.relicCount = level.difficulty == .easy ? 4 : (level.difficulty == .normal ? 5 : 6)
        reset()
    }

    var gridColumns: Int {
        level.difficulty == .hard ? 4 : 3
    }

    func reset() {
        timer?.invalidate()
        hintsUsed = 0
        let totalTiles = level.difficulty == .easy ? 12 : (level.difficulty == .normal ? 16 : 20)
        let relicIndexes = Set((0..<totalTiles).shuffled().prefix(relicCount))
        tiles = (0..<totalTiles).map { Tile(isRelic: relicIndexes.contains($0)) }
        timeLeft = level.difficulty == .easy ? 80 : (level.difficulty == .normal ? 60 : 45)
        startTime = Date()
        startTimer()
    }

    func tapTile(_ tile: Tile) {
        guard let index = tiles.firstIndex(where: { $0.id == tile.id }), !tiles[index].isRevealed else { return }
        tiles[index].isRevealed = true
        if tiles.filter({ $0.isRelic && $0.isRevealed }).count == relicCount {
            finish()
        }
    }

    func useHint() {
        guard hintsUsed < 2, let index = tiles.firstIndex(where: { $0.isRelic && !$0.isRevealed }) else { return }
        hintsUsed += 1
        tiles[index].isRevealed = true
        if tiles.filter({ $0.isRelic && $0.isRevealed }).count == relicCount {
            finish()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.timeLeft -= 1
            if self.timeLeft <= 0 {
                self.finish()
            }
        }
    }

    private func finish() {
        timer?.invalidate()
        let foundCount = tiles.filter({ $0.isRelic && $0.isRevealed }).count
        let elapsed = Date().timeIntervalSince(startTime)
        let completion = Double(foundCount) / Double(relicCount)
        var stars = completion >= 1 ? 3 : (completion >= 0.6 ? 2 : 1)
        if hintsUsed > 0 { stars = max(1, stars - 1) }
        if timeLeft <= 0 && completion < 1 { stars = 1 }
        lastResult = ActivityResult(levelID: level.id, stars: stars, timeTaken: elapsed, hintsUsed: hintsUsed, choicesMade: 0)
        showResult = true
    }
}
