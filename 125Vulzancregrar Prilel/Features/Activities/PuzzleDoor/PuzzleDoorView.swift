//
//  PuzzleDoorView.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import SwiftUI

struct PuzzleDoorView: View {
    let level: Level
    @EnvironmentObject private var appStorage: AppStorage
    @StateObject private var viewModel: PuzzleDoorViewModel

    init(level: Level) {
        self.level = level
        _viewModel = StateObject(wrappedValue: PuzzleDoorViewModel(level: level))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Align all rings to unlock the door.")
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Moves: \(viewModel.moves)")
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .adventureCard()
                .adventureShimmer()

                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface, Color.appBackground.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 260)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.appAccent.opacity(0.22), lineWidth: 1)
                        )
                        .shadow(color: Color.appBackground.opacity(0.3), radius: 14, x: 0, y: 8)
                    VStack(spacing: 16) {
                        ForEach(0..<3, id: \.self) { idx in
                            Button {
                                viewModel.rotateRing(index: idx)
                            } label: {
                                HStack {
                                    Circle()
                                        .stroke(Color.appAccent, lineWidth: 6)
                                        .frame(width: 54, height: 54)
                                        .overlay(Text("\(viewModel.rings[idx])").foregroundStyle(Color.appTextPrimary))
                                    Text("Rotate Ring \(idx + 1)")
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .frame(minHeight: 56)
                                .background(Color.appBackground.opacity(0.55))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Door Opening")
                        .foregroundStyle(Color.appTextSecondary)
                    ProgressView(value: viewModel.doorProgress)
                        .tint(Color.appAccent)
                }
                .padding(14)
                .adventureCard()
                .adventureShimmer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(AdventureBackground())
        .navigationTitle("Ancient Puzzle Door")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.showResult) {
            if let result = viewModel.lastResult {
                ResultView(level: level, result: result) { appStorage.apply(result: result) } onRetry: {
                    viewModel.reset()
                }
            }
        }
    }
}
