import SwiftUI

/// Bespoke palette for Caulkline. Not shared with other apps in the portfolio.
enum Theme {
    static let background = Color(red: 0.059, green: 0.090, blue: 0.086)
    static let surface = Color(red: 0.094, green: 0.141, blue: 0.133)
    static let accent = Color(red: 0.373, green: 0.659, blue: 0.627)
    static let textPrimary = Color(red: 0.906, green: 0.949, blue: 0.941)
    static let textMuted = Color(red: 0.498, green: 0.639, blue: 0.616)

    static let titleFont: Font = .system(.title2, design: .rounded).weight(.bold)
    static let headlineFont: Font = .system(.headline, design: .rounded)
    static let bodyFont: Font = .system(.body, design: .rounded)
    static let captionFont: Font = .system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 16
}
