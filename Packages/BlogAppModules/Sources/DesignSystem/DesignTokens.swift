import SwiftUI

public enum PulseColor {
    public static let accent = Color(red: 0.36, green: 0.27, blue: 0.93)
    public static let accentSoft = accent.opacity(0.14)
    public static let pageBackground = Color.primary.opacity(0.04)
    public static let cardBackground = Color.primary.opacity(0.05)
    public static let cardBorder = Color.primary.opacity(0.07)
    public static let secondaryText = Color.secondary
    public static let badgeBackground = Color.primary.opacity(0.06)
    public static let badgeText = Color.secondary
    public static let shimmerBase = Color.primary.opacity(0.08)
    public static let shimmerHighlight = Color.white.opacity(0.45)
    public static let placeholderIcon = Color.primary.opacity(0.25)
}

public enum PulseFont {
    public static let cardTitle = Font.system(.headline, design: .rounded)
    public static let meta = Font.footnote
    public static let author = Font.system(.footnote, design: .default).weight(.medium)
    public static let badge = Font.system(.caption2, design: .default).weight(.semibold)
}
