import SwiftUI

struct DesignTokens {
    // Layout
    static let cardCornerRadius: CGFloat = 12
    static let iconCornerRadius: CGFloat = 8
    static let defaultPadding: CGFloat = 16
    static let rowHorizontalPadding: CGFloat = 12
    static let rowVerticalPadding: CGFloat = 10
    static let popoverWidth: CGFloat = 320
    
    // Colors & Materials
    @ViewBuilder
    static var cardBackground: some View {
        if #available(macOS 14.0, *) {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(.regularMaterial)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        } else {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
        }
    }
    
    @ViewBuilder
    static func cardStroke() -> some View {
        RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
            .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
            .blendMode(.overlay)
    }

    static var rowHoverBackground: Color {
        Color.primary.opacity(0.04)
    }
    
    static var rowDividerColor: Color {
        Color.primary.opacity(0.05)
    }
    
    // Typography
    static var sectionHeaderFont: Font {
        .system(size: 11, weight: .semibold, design: .default)
    }
    
    static var rowTitleFont: Font {
        .system(size: 13, weight: .medium, design: .default)
    }
    
    static var rowValueFont: Font {
        .system(size: 12, weight: .regular, design: .monospaced)
    }
}
