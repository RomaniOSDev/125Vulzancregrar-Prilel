import SwiftUI

struct RelicHuntView: View {
    let level: Level
    @StateObject private var viewModel: RelicHuntViewModel
    @EnvironmentObject private var appStorage: AppStorage

    init(level: Level) {
        self.level = level
        _viewModel = StateObject(wrappedValue: RelicHuntViewModel(level: level))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: viewModel.gridColumns), spacing: 10) {
                    ForEach(viewModel.tiles) { tile in
                        Button {
                            viewModel.tapTile(tile)
                        } label: {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(tile.isRevealed ? (tile.isRelic ? Color.appAccent : Color.appSurface.opacity(0.9)) : Color.appSurface.opacity(0.6))
                                .frame(height: 74)
                                .overlay(
                                    Image(systemName: tile.isRevealed ? (tile.isRelic ? "diamond.fill" : "leaf.fill") : "questionmark")
                                        .foregroundStyle(tile.isRevealed ? Color.appTextPrimary : Color.appTextSecondary)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.appBackground.opacity(0.25), radius: 6, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .frame(minHeight: 44)
                    }
                }

                PrimaryButton(title: "Use Hint") { viewModel.useHint() }
                    .disabled(viewModel.hintsUsed >= 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(AdventureBackground())
        .navigationTitle("Jungle Relic Hunt")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.showResult) {
            if let result = viewModel.lastResult {
                ResultView(level: level, result: result) { appStorage.apply(result: result) } onRetry: {
                    viewModel.reset()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Find all relics before time runs out.")
                .foregroundStyle(Color.appTextPrimary)
            Text("Time: \(viewModel.timeLeft)s  |  Hints: \(2 - viewModel.hintsUsed)")
                .foregroundStyle(Color.appTextSecondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .adventureCard()
        .adventureShimmer()
    }
}
