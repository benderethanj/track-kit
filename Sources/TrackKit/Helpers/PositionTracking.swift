import SwiftUI

struct ScrollViewPositionPreferenceKey: @preconcurrency PreferenceKey {
    @MainActor static let defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct PositionTrackingModifier: ViewModifier {
    let id: String

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: ScrollViewPositionPreferenceKey.self,
                            value: [id: geometry.frame(in: .named("track"))]
                        )
                }
            )
    }
}

extension View {
    func track(_ id: String) -> some View {
        self.modifier(PositionTrackingModifier(id: id))
    }
}

@MainActor
final class PositionsStore: ObservableObject {
    @Published var positions: [String: CGRect] = [:]
    
    func updatePositions(newPositions: [String: CGRect], proxy: TrackProxy) {
        for (key, rect) in newPositions {
            let x: CGFloat
            let y: CGFloat
            
            if proxy.direction == .normal {
                x = rect.origin.x
                y = rect.origin.y
            } else {
                x = proxy.size.width - rect.origin.x
                y = proxy.size.height - rect.origin.y
            }
            
            let updatedRect = CGRect(x: x, y: y, width: rect.width, height: rect.height)
            positions[key] = updatedRect
        }
    }
}
