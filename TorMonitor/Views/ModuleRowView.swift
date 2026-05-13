import SwiftUI

struct ModuleRowView: View, Equatable {
    let icon: String
    let color: Color
    let title: String
    let isOn: Bool
    let hasDivider: Bool
    let isReadOnly: Bool
    let onChanged: ((Bool) -> Void)?
    
    @State private var isHovered: Bool = false
    
    init(icon: String, color: Color, title: String, isOn: Bool, hasDivider: Bool = true, isReadOnly: Bool = false, onChanged: ((Bool) -> Void)? = nil) {
        self.icon = icon
        self.color = color
        self.title = title
        self.isOn = isOn
        self.hasDivider = hasDivider
        self.isReadOnly = isReadOnly
        self.onChanged = onChanged
    }

    static func == (lhs: ModuleRowView, rhs: ModuleRowView) -> Bool {
        return lhs.icon == rhs.icon &&
               lhs.color == rhs.color &&
               lhs.title == rhs.title &&
               lhs.isOn == rhs.isOn &&
               lhs.hasDivider == rhs.hasDivider &&
               lhs.isReadOnly == rhs.isReadOnly
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if hasDivider {
                Divider()
                    .background(DesignTokens.rowDividerColor)
                    .padding(.leading, 44) // Align with text
            }
            
            HStack(spacing: 12) {
                // Icon with colored background
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.iconCornerRadius, style: .continuous)
                        .fill(color.opacity(isOn ? 1.0 : 0.8))
                        .frame(width: 26, height: 26)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Title and Status Indicator
                HStack(spacing: 6) {
                    Text(title)
                        .font(DesignTokens.rowTitleFont)
                        .foregroundColor(isOn ? .primary : .primary.opacity(0.8))
                    
                    if isOn && !isReadOnly {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 5, height: 5)
                            .opacity(0.8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Control
                if isReadOnly {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))
                } else if let onChanged = onChanged {
                    AppKitSwitch(label: title, isOn: isOn, onChanged: onChanged)
                        .frame(width: 38, height: 22)
                }
            }
            .padding(.horizontal, DesignTokens.rowHorizontalPadding)
            .padding(.vertical, DesignTokens.rowVerticalPadding)
            .background(isHovered ? DesignTokens.rowHoverBackground : Color.clear)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
        }
    }
}
