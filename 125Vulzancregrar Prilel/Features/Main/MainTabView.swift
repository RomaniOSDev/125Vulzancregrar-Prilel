import SwiftUI

enum MainTab: CaseIterable {
    case home
    case questLog
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .questLog: return "Quest Log"
        case .settings: return "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .questLog: return "list.bullet.rectangle.portrait.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            AdventureBackground()
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .questLog: QuestLogView()
                case .settings: SettingsView()
                }
            }
            .padding(.bottom, 86)

            HStack(spacing: 12) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.symbol)
                            Text(tab.title)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .foregroundStyle(selectedTab == tab ? Color.appTextPrimary : Color.appTextSecondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(.vertical, 10)
                        .background(
                            selectedTab == tab
                            ? LinearGradient(colors: [Color.appPrimary, Color.appAccent], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.clear, Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(selectedTab == tab ? Color.appTextPrimary.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .shadow(color: selectedTab == tab ? Color.appAccent.opacity(0.35) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(AdventurePressButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.appSurface.opacity(0.95), Color.appBackground.opacity(0.75)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.appBackground.opacity(0.48), radius: 18, x: 0, y: 12)
            .shadow(color: Color.appAccent.opacity(0.2), radius: 5, x: 0, y: -1)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
    }
}
