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
