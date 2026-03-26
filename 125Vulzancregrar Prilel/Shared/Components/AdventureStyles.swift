//
//  AdventureStyles.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import SwiftUI

struct AdventureCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        Color.appSurface.opacity(0.98 * intensity),
                        Color.appPrimary.opacity(0.22 * intensity),
                        Color.appBackground.opacity(0.62 * intensity)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                LinearGradient(
                    colors: [Color.appTextPrimary.opacity(0.14), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .center
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .allowsHitTesting(false)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
                    .allowsHitTesting(false)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.appBackground.opacity(0.48), radius: 20, x: 0, y: 12)
            .shadow(color: Color.appAccent.opacity(0.24), radius: 6, x: 0, y: -2)
    }
}

struct AdventureGlowPulseModifier: ViewModifier {
    @State private var glowing = false

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.appAccent.opacity(glowing ? 0.34 : 0.16), radius: glowing ? 14 : 6, x: 0, y: 0)
            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: glowing)
            .onAppear { glowing = true }
    }
}

struct AdventurePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .shadow(color: Color.appBackground.opacity(configuration.isPressed ? 0.2 : 0.35), radius: configuration.isPressed ? 4 : 10, x: 0, y: configuration.isPressed ? 2 : 6)
            .animation(.spring(response: 0.25, dampingFraction: 0.76), value: configuration.isPressed)
    }
}

struct AdventureShimmerModifier: ViewModifier {
    @State private var move = false
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.appTextPrimary.opacity(0.18), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(-13))
                    .offset(x: move ? 280 : -280)
                    .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: false), value: move)
                    .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .allowsHitTesting(false)
            )
            .onAppear { move = true }
    }
}

extension View {
    func adventureCard(cornerRadius: CGFloat = 14, intensity: Double = 1) -> some View {
        modifier(AdventureCardModifier(cornerRadius: cornerRadius, intensity: intensity))
    }

    func adventureGlowPulse() -> some View {
        modifier(AdventureGlowPulseModifier())
    }

    func adventureShimmer(cornerRadius: CGFloat = 14) -> some View {
        modifier(AdventureShimmerModifier(cornerRadius: cornerRadius))
    }
}
