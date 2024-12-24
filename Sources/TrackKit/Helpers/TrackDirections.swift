import Foundation

public enum TrackDirection {
    case normal, reverse
}

struct TrackSet: OptionSet {
    let rawValue: Int

    static let verticalStart = TrackSet(rawValue: 1 << 0)
    static let verticalCenter = TrackSet(rawValue: 1 << 1)
    static let verticalEnd = TrackSet(rawValue: 1 << 2)
    static let horizontalStart = TrackSet(rawValue: 1 << 3)
    static let horizontalCenter = TrackSet(rawValue: 1 << 4)
    static let horizontalEnd = TrackSet(rawValue: 1 << 5)

    static let top: TrackSet = .verticalStart
    static let bottom: TrackSet = .verticalEnd
    
    static let leading: TrackSet = .horizontalStart
    static let trailing: TrackSet = .horizontalEnd
    
    static let center: TrackSet = [.verticalCenter, .horizontalCenter]
}
