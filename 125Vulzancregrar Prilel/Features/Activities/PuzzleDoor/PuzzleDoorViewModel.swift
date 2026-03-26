//
//  PuzzleDoorViewModel.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import Foundation
import SwiftUI
import Combine

final class PuzzleDoorViewModel: ObservableObject {
    @Published var rings: [Int] = [0, 0, 0]
    @Published var moves = 0
    @Published var showResult = false
    @Published var doorProgress: Double = 0
    @Published var lastResult: ActivityResult?

    private let level: Level
    private let target: [Int]
    private let startTime = Date()

    init(level: Level) {
        self.level = level
        switch level.difficulty {
        case .easy: target = [1, 2, 3]
        case .normal: target = [2, 4, 1]
        case .hard: target = [5, 0, 3]
        }
    }

    func rotateRing(index: Int) {
        guard rings.indices.contains(index) else { return }
        rings[index] = (rings[index] + 1) % 6
        moves += 1
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            let correct = zip(rings, target).filter { $0 == $1 }.count
            doorProgress = Double(correct) / Double(target.count)
        }
        if rings == target {
            finish()
        }
    }

    private func finish() {
        let elapsed = Date().timeIntervalSince(startTime)
        let baseline = level.difficulty == .easy ? 12 : (level.difficulty == .normal ? 15 : 18)
        let stars: Int
        if moves <= baseline {
            stars = 3
        } else if moves <= baseline + 6 {
            stars = 2
        } else {
            stars = 1
        }
        lastResult = ActivityResult(levelID: level.id, stars: stars, timeTaken: elapsed, hintsUsed: 0, choicesMade: moves)
        showResult = true
    }

    func reset() {
        rings = [0, 0, 0]
        moves = 0
        doorProgress = 0
    }
}
