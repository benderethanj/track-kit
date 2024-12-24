import SwiftUI

public extension TrackProxy {
    func scroll(to offset: CGPoint, animation: Animation? = .default) {
        self.drag?.velocity = .zero
        self.drag?.acceleration = .zero
        withAnimation(animation) {
            self.offset.width = offset.x
            self.offset.height = offset.y
        }
    }
    
    func scroll(by offset: CGSize, animation: Animation? = .default) {
        withAnimation(animation) {
            self.offset.width += offset.width
            self.offset.height += offset.height
        }
    }
}

@Observable
public class TrackProxy {
    var offset: CGSize = .zero
    
    var frame: CGRect = .zero
    var size: CGSize = .zero
    
    var axis: Axis.Set
    var direction: TrackDirection
    var positions: [AnyHashable: CGRect] = [:]
    
    var friction: CGFloat
    var resistance: CGFloat
    
    var drag: DragEngine?

    init(axis: Axis.Set = .vertical, direction: TrackDirection = .normal, friction: CGFloat = 1, resistance: CGFloat = 1) {
        self.axis = axis
        self.direction = direction
        self.friction = friction
        self.resistance = resistance
    }
    
    var directionScale: CGFloat {
        direction == .normal ? 1 : -1
    }

    func scrollTo(
        _ id: AnyHashable,
        alignment: TrackSet = .center,
        anchor: TrackSet = .center,
        restricted: Bool = true,
        animation: Animation? = .default
    ) {
        guard let rect = positions[id] else { return }
        
        let width: CGFloat = rect.width
        let height: CGFloat = rect.height
        
        var anchorOffset: CGPoint = .zero
        if axis.contains(.vertical) {
            if anchor.contains(.verticalStart) {
                anchorOffset.y = 0
            }
            if anchor.contains(.verticalCenter) {
                anchorOffset.y = directionScale * height / 2
            }
            if anchor.contains(.verticalEnd) {
                anchorOffset.y = directionScale * height
            }
        }
        if axis.contains(.horizontal) {
            if anchor.contains(.horizontalStart) {
                anchorOffset.x = 0
            }
            if anchor.contains(.horizontalCenter) {
                anchorOffset.x = directionScale * width / 2
            }
            if anchor.contains(.horizontalEnd) {
                anchorOffset.x = directionScale * width
            }
        }
        
        var alignmentOffset: CGPoint = .zero
        if axis.contains(.vertical) {
            if alignment.contains(.verticalStart) {
                alignmentOffset.y = -frame.height / 2 + directionScale * frame.height / 2
            }
            if alignment.contains(.verticalCenter) {
                alignmentOffset.y = -frame.height / 2
            }
            if alignment.contains(.verticalEnd) {
                alignmentOffset.y = -frame.height / 2 - directionScale * frame.height / 2
            }
        }
        if axis.contains(.horizontal) {
            if alignment.contains(.horizontalStart) {
                alignmentOffset.x = -frame.width / 2 + directionScale * frame.width / 2
            }
            if alignment.contains(.horizontalCenter) {
                alignmentOffset.x = -frame.width / 2
            }
            if alignment.contains(.horizontalEnd) {
                alignmentOffset.x = -frame.width / 2 - directionScale * frame.width / 2
            }
        }
        
        var offset: CGPoint = .zero
        if axis.contains(.vertical) {
            offset.y = rect.origin.y + alignmentOffset.y + anchorOffset.y
        }
        if axis.contains(.horizontal) {
            offset.x = rect.origin.x + alignmentOffset.x + anchorOffset.x
        }

        if restricted {
            let maxOffsetX = max(0, size.width - frame.width)
            let maxOffsetY = max(0, size.height - frame.height)
            offset.x = min(max(0, offset.x), maxOffsetX)
            offset.y = min(max(0, offset.y), maxOffsetY)
        }
        
        scroll(to: offset, animation: animation)
    }
    
    var overflow: CGSize {
        let maxOffsetX = max(0, self.size.width - self.frame.width)
        let maxOffsetY = max(0, self.size.height - self.frame.height)
        
        var value: CGSize = .zero
        
        switch min(max(0, self.offset.width), maxOffsetX) {
        case 0:
            value.width = self.offset.width
        case maxOffsetX:
            value.width = self.offset.width - maxOffsetX
        default:
            value.width = 0
        }
        
        switch min(max(0, self.offset.height), maxOffsetY) {
        case 0:
            value.height = self.offset.height
        case maxOffsetY:
            value.height = self.offset.height - maxOffsetY
        default:
            value.height = 0
        }
        
        return value
    }
}
