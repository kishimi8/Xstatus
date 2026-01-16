import SwiftUI

public struct GlassCard<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - GlassSlider
struct GlassSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 6)
                
                // Active Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.8))
                    .frame(width: max(0, CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width), height: 6)
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 0)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 14, height: 14)
                    .shadow(radius: 2)
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 7)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let newValue = Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                                self.value = min(max(newValue, range.lowerBound), range.upperBound)
                            }
                    )
            }
            .frame(height: 14)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .frame(height: 14)
    }
}

// MARK: - GlassPicker
struct GlassPicker<T: Hashable & CustomStringConvertible>: View {
    @Binding var selection: T
    let options: [T]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Text(option.description)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(selection == option ? Color.white.opacity(0.15) : Color.clear)
                    .cornerRadius(6)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selection = option
                        }
                    }
            }
        }
        .padding(2)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(8)
    }
}

public struct LiquidUsageBar: View {
    let value: Double // 0.0 to 1.0
    let colors: [Color]
    
    public init(value: Double, colors: [Color] = [.blue.opacity(0.8), .cyan.opacity(0.6)]) {
        self.value = max(0, min(1, value))
        self.colors = colors
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.05))
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(value))
                    .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 4, x: 0, y: 0)
            }
        }
    }
}

public struct GlassLabel: View {
    let title: String
    let icon: String
    let color: Color
    
    public init(_ title: String, systemImage: String, color: Color = .primary) {
        self.title = title
        self.icon = systemImage
        self.color = color
    }
    
    public var body: some View {
        Label {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
        } icon: {
            Image(systemImage: icon)
                .foregroundColor(color)
                .font(.caption)
        }
    }
}

public struct GlassValueRow: View {
    let label: String
    let value: String
    let icon: String?
    
    public init(label: String, value: String, icon: String? = nil) {
        self.label = label
        self.value = value
        self.icon = icon
    }
    
    public var body: some View {
        HStack {
            if let icon = icon {
                Image(systemImage: icon)
                    .foregroundColor(.secondary)
                    .font(.caption2)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
        }
    }
}

extension View {
    public func glassBackground() -> some View {
        self.modifier(GlassModifier())
    }
}

struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
