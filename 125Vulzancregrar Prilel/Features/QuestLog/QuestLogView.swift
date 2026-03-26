//
//  QuestLogView.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import SwiftUI

struct QuestLogView: View {
    @EnvironmentObject private var appStorage: AppStorage

    var body: some View {
        NavigationStack {
            List {
                Section("Rewards") {
                    HStack {
                        Text("Rank")
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                        Text(appStorage.explorerRank)
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .listRowBackground(rowBackground)
                    HStack {
                        Text("Explorer XP")
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                        Text("\(appStorage.explorerXP)")
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .listRowBackground(rowBackground)
                    HStack {
                        Text("Perfect Streak")
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                        Text("\(appStorage.perfectStreak)")
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .listRowBackground(rowBackground)
                    HStack {
                        Text("Lore Fragments")
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                        Text("\(appStorage.loreFragments)")
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .listRowBackground(rowBackground)
                }

                Section("Completed Quests") {
                    if appStorage.completedLevels.isEmpty {
                        Text("No completed quests yet.")
                            .foregroundStyle(Color.appTextSecondary)
                            .listRowBackground(rowBackground)
                    } else {
                        ForEach(appStorage.completedLevels) { level in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(level.title)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text(level.difficulty.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                                Spacer()
                                Text("\(appStorage.stars(for: level.id))★")
                                    .foregroundStyle(Color.appAccent)
                            }
                            .frame(minHeight: 44)
                            .listRowBackground(rowBackground)
                        }
                    }
                }

                Section("Achievements") {
                    if appStorage.achievements.isEmpty {
                        Text("No achievements unlocked.")
                            .foregroundStyle(Color.appTextSecondary)
                            .listRowBackground(rowBackground)
                    } else {
                        ForEach(appStorage.achievements, id: \.self) { achievement in
                            Text(achievement)
                                .foregroundStyle(Color.appTextPrimary)
                                .frame(minHeight: 44, alignment: .leading)
                                .listRowBackground(rowBackground)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AdventureBackground())
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.15), lineWidth: 1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            )
            .navigationTitle("Quest Log")
        }
    }

    private var rowBackground: some View {
        LinearGradient(
            colors: [Color.appSurface.opacity(0.95), Color.appBackground.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
