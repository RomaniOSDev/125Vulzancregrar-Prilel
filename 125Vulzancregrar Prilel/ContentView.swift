//
//  ContentView.swift
//  125Vulzancregrar Prilel
//
//  Created by Роман Главацкий on 26.03.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appStorage = AppStorage()
    @State private var refreshToken = UUID()

    var body: some View {
        Group {
            if appStorage.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(appStorage)
        .id(refreshToken)
        .onReceive(NotificationCenter.default.publisher(for: .appStorageDidReset)) { _ in
            refreshToken = UUID()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
