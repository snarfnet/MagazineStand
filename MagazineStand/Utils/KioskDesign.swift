import SwiftUI

enum Kiosk {
    static let ink = Color(red: 0.045, green: 0.045, blue: 0.055)
    static let asphalt = Color(red: 0.065, green: 0.075, blue: 0.085)
    static let shelf = Color(red: 0.13, green: 0.145, blue: 0.155)
    static let shelfEdge = Color(red: 0.46, green: 0.48, blue: 0.46)
    static let paper = Color(red: 0.96, green: 0.91, blue: 0.82)
    static let dimPaper = Color(red: 0.71, green: 0.65, blue: 0.56)
    static let neonRed = Color(red: 0.72, green: 0.08, blue: 0.06)
    static let signalCyan = Color(red: 0.13, green: 0.64, blue: 0.78)
    static let gold = Color(red: 0.96, green: 0.68, blue: 0.12)
    static let violet = Color(red: 0.56, green: 0.24, blue: 0.92)
    static let green = Color(red: 0.10, green: 0.62, blue: 0.35)

    static let screenBackground = LinearGradient(
        colors: [Color(red: 0.035, green: 0.040, blue: 0.048), Color(red: 0.095, green: 0.085, blue: 0.075)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroGlow = LinearGradient(
        colors: [gold.opacity(0.30), signalCyan.opacity(0.18), neonRed.opacity(0.24)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let coverPalettes: [[Color]] = [
        [neonRed, Color(red: 0.12, green: 0.04, blue: 0.05)],
        [signalCyan, Color(red: 0.04, green: 0.13, blue: 0.16)],
        [gold, Color(red: 0.24, green: 0.14, blue: 0.04)],
        [violet, Color(red: 0.13, green: 0.07, blue: 0.18)],
        [green, Color(red: 0.03, green: 0.14, blue: 0.08)],
        [Color(red: 0.94, green: 0.38, blue: 0.12), Color(red: 0.16, green: 0.07, blue: 0.03)]
    ]

    static func palette(for key: String) -> [Color] {
        let value = abs(key.hashValue)
        return coverPalettes[value % coverPalettes.count]
    }

    static func shelfRail(height: CGFloat = 10) -> some View {
        Capsule()
            .fill(
                LinearGradient(colors: [shelfEdge.opacity(0.92), shelf, Color.black.opacity(0.42)], startPoint: .top, endPoint: .bottom)
            )
            .frame(height: height)
            .shadow(color: .black.opacity(0.45), radius: 8, y: 5)
    }

    static func halftone(color: Color = .white.opacity(0.10)) -> some View {
        Canvas { context, size in
            let gap: CGFloat = 12
            var x: CGFloat = 0
            while x < size.width {
                var y: CGFloat = 0
                while y < size.height {
                    let rect = CGRect(x: x, y: y, width: 2.2, height: 2.2)
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                    y += gap
                }
                x += gap
            }
        }
        .allowsHitTesting(false)
    }
}

struct GlassPanel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(0.10), lineWidth: 1)
            )
    }
}

extension View {
    func glassPanel() -> some View {
        modifier(GlassPanel())
    }
}
