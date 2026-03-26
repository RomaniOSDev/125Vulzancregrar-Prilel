import Foundation
import SwiftUI
import Combine

final class TribalTrailViewModel: ObservableObject {
    struct StoryNode: Identifiable {
        struct Choice: Identifiable {
            let id = UUID()
            let text: String
            let next: Int?
            let score: Int
        }

        let id: Int
        let text: String
        let choices: [Choice]
    }

    @Published private(set) var currentNodeID = 1
    @Published private(set) var selectedChoices = 0
    @Published var showResult = false
    @Published var lastResult: ActivityResult?

    private let level: Level
    private(set) var score = 0
    private let startTime = Date()

    let nodes: [Int: StoryNode] = [
        1: StoryNode(id: 1, text: "You reach a split path beneath giant trees.", choices: [
            .init(text: "Follow drum echoes", next: 2, score: 2),
            .init(text: "Inspect old carvings", next: 3, score: 1)
        ]),
        2: StoryNode(id: 2, text: "A river blocks the route.", choices: [
            .init(text: "Build a vine bridge", next: 4, score: 2),
            .init(text: "Search for a shallow crossing", next: 4, score: 1)
        ]),
        3: StoryNode(id: 3, text: "You discover symbols pointing to a hidden camp.", choices: [
            .init(text: "Approach carefully", next: 4, score: 2),
            .init(text: "Rush to the center", next: 4, score: 0)
        ]),
        4: StoryNode(id: 4, text: "Final challenge: pick the safest relic route.", choices: [
            .init(text: "Use starlight landmarks", next: nil, score: 2),
            .init(text: "Move fast through fog", next: nil, score: 0)
        ])
    ]

    init(level: Level) {
        self.level = level
    }

    var currentNode: StoryNode {
        nodes[currentNodeID] ?? StoryNode(id: 0, text: "Path unavailable.", choices: [])
    }

    func choose(_ choice: StoryNode.Choice) {
        selectedChoices += 1
        score += choice.score
        if let next = choice.next {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentNodeID = next
            }
        } else {
            finish()
        }
    }

    func reset() {
        currentNodeID = 1
        selectedChoices = 0
        score = 0
    }

    private func finish() {
        let elapsed = Date().timeIntervalSince(startTime)
        let maxScore = 8
        let ratio = Double(score) / Double(maxScore)
        let stars = ratio >= 0.75 ? 3 : (ratio >= 0.45 ? 2 : 1)
        lastResult = ActivityResult(levelID: level.id, stars: stars, timeTaken: elapsed, hintsUsed: 0, choicesMade: selectedChoices)
        showResult = true
    }
}
