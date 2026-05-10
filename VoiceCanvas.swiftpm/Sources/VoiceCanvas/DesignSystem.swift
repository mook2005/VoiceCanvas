import SwiftUI

struct AC {
    static let primary      = Color(red: 0.33, green: 0.34, blue: 0.84)
    static let primaryLight = Color(red: 0.91, green: 0.91, blue: 0.98)
    static let primaryDark  = Color(red: 0.20, green: 0.20, blue: 0.65)
    static let background   = Color(red: 0.98, green: 0.98, blue: 1.00)
    static let canvas       = Color.white
    static let surface      = Color(red: 0.96, green: 0.96, blue: 0.99)
    static let textPrimary  = Color(red: 0.10, green: 0.10, blue: 0.18)
    static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.55)
    static let success      = Color(red: 0.18, green: 0.72, blue: 0.52)
    static let warning      = Color(red: 0.97, green: 0.62, blue: 0.22)
    static let danger       = Color(red: 0.90, green: 0.28, blue: 0.28)
    static let stroke       = Color(red: 0.10, green: 0.10, blue: 0.20)

    static let corner: CGFloat       = 20
    static let cardCorner: CGFloat   = 16
    static let btnCorner: CGFloat    = 14
    static let strokeWidth: CGFloat  = 7
    static let pad: CGFloat          = 20
}

extension Font {
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
