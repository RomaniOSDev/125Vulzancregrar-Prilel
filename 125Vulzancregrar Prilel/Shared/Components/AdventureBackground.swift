//
//  AdventureBackground.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import SwiftUI

struct AdventureBackground: View {
    var body: some View {
        ZStack {
            baseGradient
            hillsLayer
            ambientGlowLayer
        }
        .ignoresSafeArea()
    }

    private var baseGradient: some View {
        LinearGradient(
            colors: [Color.appBackground, Color.appSurface.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var hillsLayer: some View {
        Canvas { context, size in
            for index in 0..<7 {
                let y = size.height * (0.45 + CGFloat(index) * 0.08)
                var hill = Path()
                hill.move(to: CGPoint(x: 0, y: y))
                hill.addCurve(
                    to: CGPoint(x: size.width, y: y),
                    control1: CGPoint(x: size.width * 0.25, y: y - 55),
                    control2: CGPoint(x: size.width * 0.75, y: y + 45)
                )
                hill.addLine(to: CGPoint(x: size.width, y: size.height))
                hill.addLine(to: CGPoint(x: 0, y: size.height))
                hill.closeSubpath()
                let fill = index.isMultiple(of: 2) ? Color.appSurface.opacity(0.35) : Color.appAccent.opacity(0.2)
                context.fill(hill, with: .color(fill))
            }
        }
    }

    private var ambientGlowLayer: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                drawGlow(at: CGPoint(x: size.width * (0.18 + 0.06 * sin(t * 0.35)), y: size.height * (0.2 + 0.03 * cos(t * 0.4))), radius: 130, in: &context)
                drawGlow(at: CGPoint(x: size.width * (0.8 + 0.05 * cos(t * 0.28)), y: size.height * (0.3 + 0.04 * sin(t * 0.33))), radius: 160, in: &context)
                drawGlow(at: CGPoint(x: size.width * (0.5 + 0.04 * sin(t * 0.2)), y: size.height * (0.12 + 0.03 * cos(t * 0.22))), radius: 110, in: &context)
            }
        }
    }

    private func drawGlow(at point: CGPoint, radius: CGFloat, in context: inout GraphicsContext) {
        let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: rect), with: .color(Color.appAccent.opacity(0.08)))
    }
}
