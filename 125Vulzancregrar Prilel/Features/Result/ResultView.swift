//
//  ResultView.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import SwiftUI

struct ResultView: View {
    let level: Level
    let result: ActivityResult
    let onSave: () -> RewardOutcome
    let onRetry: () -> Void

    @EnvironmentObject private var appStorage: AppStorage
    @Environment(\.dismiss) private var dismiss
    @State private var visibleStars = 0
    @State private var rewardOutcome = RewardOutcome(achievementsUnlocked: [], xpGained: 0, streak: 0, loreFragmentsUnlocked: 0)
    @State private var showBanner = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if showBanner, let first = rewardOutcome.achievementsUnlocked.first {
                    Text("Achievement Unlocked: \(first)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .adventureCard(cornerRadius: 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Text("Quest Complete")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: 14) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < visibleStars ? "star.fill" : "star")
                            .font(.system(size: 34))
                            .foregroundStyle(index < visibleStars ? Color.appAccent : Color.appTextSecondary)
                            .shadow(color: index < visibleStars ? Color.appAccent.opacity(0.8) : .clear, radius: 8)
                            .scaleEffect(index < visibleStars ? 1 : 0.92)
                            .animation(.spring(response: 0.42, dampingFraction: 0.7), value: visibleStars)
                    }
                }

                statsCard
                rewardCard

                PrimaryButton(title: nextLevelTitle) {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let next = appStorage.levels.first(where: { $0.id == level.id + 1 }), appStorage.isUnlocked(next) {
                            NotificationCenter.default.post(name: Notification.Name("openLevel"), object: next)
                        }
                    }
                }
                PrimaryButton(title: "Retry") {
                    onRetry()
                    dismiss()
                }
                PrimaryButton(title: "Back to Levels") {
                    dismiss()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(AdventureBackground())
        .onAppear {
            rewardOutcome = onSave()
            if !rewardOutcome.achievementsUnlocked.isEmpty {
                withAnimation(.easeInOut(duration: 0.3)) { showBanner = true }
            }
            for index in 0..<result.stars {
                let delay = Double(index) * 0.15
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                        visibleStars = max(visibleStars, index + 1)
                    }
                }
            }
        }
    }

    private var nextLevelTitle: String {
        level.id < appStorage.levels.count ? "Next Level" : "All Levels Completed"
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time: \(appStorage.format(time: result.timeTaken))")
                .foregroundStyle(Color.appTextPrimary)
            Text("Stars: \(result.stars)")
                .foregroundStyle(Color.appTextPrimary)
            Text("Hints Used: \(result.hintsUsed)")
                .foregroundStyle(Color.appTextPrimary)
            Text("Path Choices: \(result.choicesMade)")
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .adventureCard()
        .adventureShimmer()
    }

    private var rewardCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("XP Gained: \(rewardOutcome.xpGained)")
                .foregroundStyle(Color.appTextPrimary)
            Text("Perfect Streak: \(rewardOutcome.streak)")
                .foregroundStyle(Color.appTextPrimary)
            Text("Lore Fragments: +\(rewardOutcome.loreFragmentsUnlocked)")
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .adventureCard()
        .adventureShimmer()
    }
}
