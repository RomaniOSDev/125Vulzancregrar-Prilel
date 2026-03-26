//
//  ActivityRouterView.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import SwiftUI

struct ActivityRouterView: View {
    let level: Level

    var body: some View {
        switch level.activity {
        case .relicHunt:
            RelicHuntView(level: level)
        case .puzzleDoor:
            PuzzleDoorView(level: level)
        case .tribalTrail:
            TribalTrailView(level: level)
        }
    }
}
