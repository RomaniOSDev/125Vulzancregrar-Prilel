import SwiftUI

struct TribalTrailView: View {
    let level: Level
    @EnvironmentObject private var appStorage: AppStorage
    @StateObject private var viewModel: TribalTrailViewModel

    init(level: Level) {
        self.level = level
        _viewModel = StateObject(wrappedValue: TribalTrailViewModel(level: level))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Choose wisely to shape the quest.")
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(12)
                    .adventureCard()
                    .adventureShimmer()

                List {
                    Section("Current Story") {
                        Text(viewModel.currentNode.text)
                            .foregroundStyle(Color.appTextPrimary)
                            .listRowBackground(rowBackground)
                    }
                    Section("Decisions") {
                        ForEach(viewModel.currentNode.choices) { choice in
                            Button {
                                viewModel.choose(choice)
                            } label: {
                                Text(choice.text)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                                    .foregroundStyle(Color.appTextPrimary)
                                    .frame(minHeight: 44, alignment: .leading)
                            }
                            .listRowBackground(rowBackground)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .frame(height: 340)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.28), lineWidth: 1)
                )
                .shadow(color: Color.appBackground.opacity(0.45), radius: 16, x: 0, y: 10)
                .shadow(color: Color.appAccent.opacity(0.16), radius: 4, x: 0, y: -1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(AdventureBackground())
        .navigationTitle("Tribal Trail Quest")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.showResult) {
            if let result = viewModel.lastResult {
                ResultView(level: level, result: result) { appStorage.apply(result: result) } onRetry: {
                    viewModel.reset()
                }
            }
        }
    }

    private var rowBackground: some View {
        LinearGradient(
            colors: [Color.appSurface.opacity(0.95), Color.appBackground.opacity(0.68)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
