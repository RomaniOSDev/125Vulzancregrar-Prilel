//
//  ExploreView.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var appStorage: AppStorage
    @State private var path: [Level] = []

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AdventureBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.appTextPrimary)

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(appStorage.levels.filter { $0.difficulty == difficulty }) { level in
                                    NavigationLink(value: level) {
                                        LevelCard(level: level, stars: appStorage.stars(for: level.id), isUnlocked: appStorage.isUnlocked(level))
                                    }
                                    .disabled(!appStorage.isUnlocked(level))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 22)
                }
            }
            .background(Color.clear)
            .navigationDestination(for: Level.self) { level in
                ActivityRouterView(level: level)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("openLevel"))) { output in
                guard let level = output.object as? Level else { return }
                path.append(level)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Adventure Path")
                        .foregroundStyle(Color.appTextPrimary)
                        .font(.headline)
                }
            }
        }
    }
}

private struct LevelCard: View {
    let level: Level
    let stars: Int
    let isUnlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(level.title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(minWidth: 20, minHeight: 20)
                }
            }
            Text(activityTitle)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < stars ? "star.fill" : "star")
                        .foregroundStyle(index < stars ? Color.appAccent : Color.appTextSecondary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
        .adventureCard(intensity: isUnlocked ? 1 : 0.75)
    }

    private var activityTitle: String {
        switch level.activity {
        case .relicHunt: return "Jungle Relic Hunt"
        case .puzzleDoor: return "Ancient Puzzle Door"
        case .tribalTrail: return "Tribal Trail Quest"
        }
    }
}
