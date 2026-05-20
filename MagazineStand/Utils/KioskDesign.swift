import SwiftUI

enum Kiosk {
    // Warm kiosk colors — wood, metal, vintage paper
    static let woodDark = Color(red: 0.22, green: 0.14, blue: 0.08)
    static let woodMid = Color(red: 0.38, green: 0.24, blue: 0.14)
    static let woodLight = Color(red: 0.52, green: 0.36, blue: 0.22)
    static let metalGray = Color(red: 0.55, green: 0.54, blue: 0.52)
    static let metalDark = Color(red: 0.28, green: 0.27, blue: 0.26)
    static let cream = Color(red: 0.96, green: 0.93, blue: 0.87)
    static let warmWhite = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let redAwning = Color(red: 0.78, green: 0.18, blue: 0.12)
    static let greenAwning = Color(red: 0.15, green: 0.42, blue: 0.22)
    static let yellowPrice = Color(red: 0.92, green: 0.72, blue: 0.12)
    static let ink = Color(red: 0.12, green: 0.1, blue: 0.08)

    static let backgroundGradient = LinearGradient(
        colors: [woodDark, Color(red: 0.16, green: 0.1, blue: 0.06)],
        startPoint: .top,
        endPoint: .bottom
    )

    static func shelfBackground() -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [woodMid, woodDark],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(woodLight.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 6, y: 4)
    }
}

struct ShelfLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .tracking(1)
            .foregroundColor(Kiosk.cream)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Kiosk.redAwning.opacity(0.85))
            .clipShape(Capsule())
    }
}

extension View {
    func shelfLabel() -> some View {
        modifier(ShelfLabelStyle())
    }
}
