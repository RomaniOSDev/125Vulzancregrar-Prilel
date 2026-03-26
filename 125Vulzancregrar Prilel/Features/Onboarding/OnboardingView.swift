//
//  OnboardingView.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appStorage: AppStorage
    @State private var page = 0
    @State private var animate = false

    var body: some View {
        ZStack {
            AdventureBackground()
            VStack(spacing: 20) {
                TabView(selection: $page) {
                    onboardingPage(title: "Navigate by Compass", subtitle: "Track hidden relic paths through the jungle.") {
                        CompassShape()
                            .stroke(Color.appAccent, lineWidth: 7)
                            .frame(width: 130, height: 130)
                            .rotationEffect(.degrees(animate ? 360 : 0))
                            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: false), value: animate)
                    }.tag(0)

                    onboardingPage(title: "Unfold Ancient Maps", subtitle: "Reveal puzzle clues and secret routes.") {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appSurface, Color.appBackground.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Path { path in
                                    path.move(to: CGPoint(x: 18, y: 22))
                                    path.addLine(to: CGPoint(x: 112, y: 98))
                                    path.move(to: CGPoint(x: 112, y: 22))
                                    path.addLine(to: CGPoint(x: 18, y: 98))
                                }
                                .stroke(Color.appAccent, lineWidth: 4)
                            )
                            .frame(width: animate ? 180 : 50, height: 120)
                            .animation(.spring(response: 0.6, dampingFraction: 0.72), value: animate)
                            .shadow(color: Color.appBackground.opacity(0.35), radius: 10, x: 0, y: 7)
                    }.tag(1)

                    onboardingPage(title: "Follow the Trail", subtitle: "Your choices shape every quest outcome.") {
                        FootprintsPath(progress: animate ? 1 : 0)
                            .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [9, 9]))
                            .frame(width: 220, height: 130)
                            .animation(.easeInOut(duration: 1.7), value: animate)
                    }.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .padding(10)
                .adventureCard(cornerRadius: 18, intensity: 1.08)
                .padding(.horizontal, 12)

                PrimaryButton(title: page == 2 ? "Start Adventure" : "Next") {
                    if page < 2 {
                        withAnimation(.easeInOut(duration: 0.25)) { page += 1 }
                        animate = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { animate = true }
                    } else {
                        appStorage.hasSeenOnboarding = true
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .onAppear { animate = true }
    }

    @ViewBuilder
    private func onboardingPage<Icon: View>(title: String, subtitle: String, @ViewBuilder icon: () -> Icon) -> some View {
        VStack(spacing: 22) {
            Spacer()
            icon()
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text(subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextSecondary)
                .padding(.horizontal, 24)
            Spacer()
        }
        .padding(.horizontal, 16)
        .adventureCard()
    }
}

private struct CompassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 12))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 12))
        path.move(to: CGPoint(x: rect.minX + 12, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - 12, y: rect.midY))
        return path
    }
}

private struct FootprintsPath: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 10, y: rect.maxY - 10))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 12, y: rect.minY + 12),
            control1: CGPoint(x: rect.width * 0.35, y: rect.height * 0.2),
            control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.8)
        )
        return path.trimmedPath(from: 0, to: progress)
    }
}
