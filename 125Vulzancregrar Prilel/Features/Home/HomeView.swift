import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appStorage: AppStorage
    @State private var path: [Level] = []
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var heroShimmer = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AdventureBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        parallaxSection(heroCard, factor: 0.06, height: 152)
                        quickStartCard
                        difficultyPicker
                        levelsGrid
                        parallaxSection(rewardsPreview, factor: 0.04, height: 126)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 22)
                }
            }
            .navigationDestination(for: Level.self) { level in
                ActivityRouterView(level: level)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("openLevel"))) { output in
                guard let level = output.object as? Level else { return }
                path.append(level)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Home")
                        .foregroundStyle(Color.appTextPrimary)
                        .font(.headline)
                }
            }
        }
        .onAppear { heroShimmer = true }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Journey Progress")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text("Rank: \(appStorage.explorerRank)")
                .foregroundStyle(Color.appTextPrimary)
            ProgressView(value: Double(appStorage.totalStars), total: Double(appStorage.totalPossibleStars))
                .tint(Color.appAccent)
            HStack {
                statPill(title: "Stars", value: "\(appStorage.totalStars)")
                statPill(title: "XP", value: "\(appStorage.explorerXP)")
                statPill(title: "Streak", value: "\(appStorage.perfectStreak)")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .adventureCard()
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.appTextPrimary.opacity(0.22), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(-10))
                .offset(x: heroShimmer ? 260 : -260)
                .animation(.easeInOut(duration: 2.3).repeatForever(autoreverses: false), value: heroShimmer)
                .mask(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .allowsHitTesting(false)
        )
    }

    private var quickStartCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Start")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text(nextLevel != nil ? "Continue your next unlocked quest." : "All quests are complete. Replay to master your score.")
                .foregroundStyle(Color.appTextSecondary)
            PrimaryButton(title: nextLevel != nil ? "Continue Quest" : "Replay Last Quest") {
                if let level = nextLevel ?? appStorage.levels.last {
                    path.append(level)
                }
            }
            .transaction { transaction in
                transaction.animation = nil
            }
        }
        .padding(14)
        .adventureCard()
    }

    private var difficultyPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose Difficulty")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            HStack(spacing: 8) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDifficulty = difficulty
                        }
                    } label: {
                        Text(difficulty.rawValue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(minHeight: 44)
                            .background(
                                selectedDifficulty == difficulty
                                ? LinearGradient(colors: [Color.appPrimary, Color.appAccent], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.appSurface, Color.appBackground.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .foregroundStyle(selectedDifficulty == difficulty ? Color.appTextPrimary : Color.appTextSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: Color.appBackground.opacity(0.25), radius: 6, x: 0, y: 4)
                    }
                    .buttonStyle(AdventurePressButtonStyle())
                }
            }
        }
    }

    private var levelsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(appStorage.levels.filter { $0.difficulty == selectedDifficulty }) { level in
                NavigationLink(value: level) {
                    HomeLevelCard(
                        level: level,
                        stars: appStorage.stars(for: level.id),
                        isUnlocked: appStorage.isUnlocked(level)
                    )
                }
                .disabled(!appStorage.isUnlocked(level))
            }
        }
    }

    private var rewardsPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reward Highlights")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text("Lore Fragments: \(appStorage.loreFragments)")
                .foregroundStyle(Color.appTextPrimary)
            Text("Best Perfect Streak: \(appStorage.bestPerfectStreak)")
                .foregroundStyle(Color.appTextPrimary)
            Text("Achievements: \(appStorage.achievements.count)")
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .adventureCard()
    }

    private var nextLevel: Level? {
        appStorage.levels.first { appStorage.isUnlocked($0) && appStorage.stars(for: $0.id) == 0 }
    }

    private func parallaxSection<Content: View>(_ content: Content, factor: CGFloat, height: CGFloat) -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .global).minY
            content
                .offset(y: -minY * factor * 0.12)
        }
        .frame(height: height)
        .overlay(alignment: .topLeading) { EmptyView() }
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(Color.appBackground.opacity(0.35))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.appAccent.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct HomeLevelCard: View {
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
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < stars ? "star.fill" : "star")
                        .foregroundStyle(index < stars ? Color.appAccent : Color.appTextSecondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
        .adventureCard(cornerRadius: 12, intensity: isUnlocked ? 1 : 0.75)
    }

    private var activityTitle: String {
        switch level.activity {
        case .relicHunt: return "Jungle Relic Hunt"
        case .puzzleDoor: return "Ancient Puzzle Door"
        case .tribalTrail: return "Tribal Trail Quest"
        }
    }
}
