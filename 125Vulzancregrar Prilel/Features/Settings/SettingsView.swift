//
//  SettingsView.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var appStorage: AppStorage
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    statsCard
                    progressionCard
                    legalCard
                    achievementsCard
                    PrimaryButton(title: "Reset All Progress") {
                        showResetAlert = true
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(AdventureBackground())
            .navigationTitle("Settings")
            .alert("Reset all progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    appStorage.resetAll()
                }
            } message: {
                Text("This action clears stars, unlocked levels, and all quest stats.")
            }
        }
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Stars: \(appStorage.totalStars)")
            Text("Activities Played: \(appStorage.totalActivitiesPlayed)")
            Text("Total Play Time: \(appStorage.format(time: appStorage.totalPlayTime))")
            Text("Unlocked Level: \(appStorage.unlockedLevel)/\(appStorage.levels.count)")
        }
        .foregroundStyle(Color.appTextPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .adventureCard()
    }

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Achievement Progress")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            if appStorage.achievements.isEmpty {
                Text("Complete quests to unlock achievements.")
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                ForEach(appStorage.achievements, id: \.self) { item in
                    Text("• \(item)")
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .adventureCard()
    }

    private var progressionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reward Progress")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text("Rank: \(appStorage.explorerRank)")
                .foregroundStyle(Color.appTextPrimary)
            Text("Explorer XP: \(appStorage.explorerXP)")
                .foregroundStyle(Color.appTextPrimary)
            if appStorage.nextRankXP > appStorage.explorerXP {
                ProgressView(value: Double(appStorage.explorerXP), total: Double(appStorage.nextRankXP))
                    .tint(Color.appAccent)
            }
            Text("Perfect Streak: \(appStorage.perfectStreak)")
                .foregroundStyle(Color.appTextPrimary)
            Text("Best Perfect Streak: \(appStorage.bestPerfectStreak)")
                .foregroundStyle(Color.appTextPrimary)
            Text("Lore Fragments: \(appStorage.loreFragments)")
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .adventureCard()
    }

    private var legalCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Support")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            legalButton(title: "Rate Us", action: rateApp)
            legalButton(title: "Privacy Policy") {
                open(link: .privacyPolicy)
            }
            legalButton(title: "Terms of Use") {
                open(link: .termsOfUse)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .adventureCard()
    }

    private func legalButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 12)
            .background(Color.appBackground.opacity(0.35))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(AdventurePressButtonStyle())
    }

    private func open(link: AppLinks) {
        if let url = URL(string: link.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
