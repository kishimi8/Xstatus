import SwiftUI
import Clock
import Kit

struct ClockStatsView: View {
    @ObservedObject var store: ClockStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassLabel("World Clock", systemImage: "clock.fill", color: .cyan)
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(store.clocks, id: \.id) { clock in
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(clock.name)
                                .font(.system(.subheadline, design: .rounded))
                                .bold()
                            Text(clock.tz == "local" ? TimeZone.current.identifier : clock.tz)
                                .font(.system(size: 9, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(clock.formatted())
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    if clock.id != store.clocks.last?.id {
                        Divider()
                            .opacity(0.2)
                    }
                }
            }
        }
        .padding()
        .frame(width: 300)
        .glassBackground()
    }
}
