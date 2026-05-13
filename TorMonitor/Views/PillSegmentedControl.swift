import SwiftUI

struct PillSegmentedControl<T: Equatable & Hashable>: View {
    let options: [T]
    let labels: (T) -> String
    @Binding var selection: T
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Text(labels(option))
                    .font(DesignTokens.rowTitleFont)
                    .foregroundColor(selection == option ? .primary : .secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .frame(minWidth: 40)
                    .background(
                        ZStack {
                            if selection == option {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color(NSColor.controlBackgroundColor))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    .matchedGeometryEffect(id: "pill", in: animation)
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selection = option
                        }
                    }
            }
        }
        .padding(2)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    @Namespace private var animation
}
