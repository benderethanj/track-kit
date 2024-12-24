import Foundation

public enum TrackDirection {
    case normal, reverse
}

public struct TrackSet: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let verticalStart = TrackSet(rawValue: 1 << 0)
    public static let verticalCenter = TrackSet(rawValue: 1 << 1)
    public static let verticalEnd = TrackSet(rawValue: 1 << 2)
    public static let horizontalStart = TrackSet(rawValue: 1 << 3)
    public static let horizontalCenter = TrackSet(rawValue: 1 << 4)
    public static let horizontalEnd = TrackSet(rawValue: 1 << 5)

    public static let top: TrackSet = .verticalStart
    public static let bottom: TrackSet = .verticalEnd
    
    public static let leading: TrackSet = .horizontalStart
    public static let trailing: TrackSet = .horizontalEnd
    
    public static let center: TrackSet = [.verticalCenter, .horizontalCenter]
}
