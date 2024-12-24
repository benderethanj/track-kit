import SwiftUI

public struct Track<Content: View>: View {
    let content: (TrackProxy) -> Content
    
    @State var proxy: TrackProxy
    @State var drag: DragEngine
    
    @State private var workItem: DispatchWorkItem?
    private let positionQueue = DispatchQueue(label: "com.track.positionQueue")
    
    public init(
        axis: Axis.Set = .vertical,
        direction: TrackDirection = .normal,
        friction: CGFloat = 1,
        resistance: CGFloat = 1,
        @ViewBuilder content: @escaping (TrackProxy) -> Content
    ) {
        let proxy = TrackProxy(axis: axis, direction: direction, friction: friction, resistance: resistance)
        let drag = DragEngine(proxy: proxy)
        proxy.drag = drag
        
        self.content = content
        self.proxy = proxy
        self.drag = drag
    }
    
    var offset: CGSize {
        if proxy.direction == .normal {
            return CGSize(width: -proxy.offset.width, height: -proxy.offset.height)
        } else {
            return proxy.offset
        }
    }
    
    var viewAlignment: Alignment {
        if proxy.axis.contains(.vertical) && proxy.axis.contains(.horizontal) {
            return proxy.direction == .normal ? .topLeading : .bottomTrailing
        } else if proxy.axis.contains(.vertical) {
            return proxy.direction == .normal ? .top : .bottom
        } else if proxy.axis.contains(.horizontal) {
            return proxy.direction == .normal ? .leading : .trailing
        } else {
            return .center
        }
    }
    
    let positionsQueue = DispatchQueue(label: "com.myApp.positionsQueue")
    
    public var body: some View {
        GeometryReader { geometry in
            content(proxy)
                .fixedSize()
                .coordinateSpace(name: "track")
                .offset(offset)
                .onPreferenceChange(ScrollViewPositionPreferenceKey.self) { newPositions in
                    positionsQueue.async {
                        Task.detached {
                            let updatedPositions = await withTaskGroup(of: (String, CGRect).self) { group in
                                for (key, rect) in newPositions {
                                    group.addTask {
                                        let (x, y): (CGFloat, CGFloat) = await MainActor.run {
                                            if proxy.direction == .normal {
                                                return (rect.origin.x, rect.origin.y)
                                            } else {
                                                return (proxy.size.width - rect.origin.x, proxy.size.height - rect.origin.y)
                                            }
                                        }
                                        let width = rect.width
                                        let height = rect.height
                                        return (key, CGRect(x: x, y: y, width: width, height: height))
                                    }
                                }
                                
                                var results: [String: CGRect] = [:]
                                for await (key, rect) in group {
                                    results[key] = rect
                                }
                                return results
                            }
                            
                            await MainActor.run {
                                throttlePositionsUpdate(updatedPositions)
                            }
                        }
                    }
                }
                .size($proxy.size)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: viewAlignment)
                .frame($proxy.frame)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { self.onDragChanged($0) }
                .onEnded { self.onDragEnded($0) }
        )
    }
    
    private func onDragChanged(_ gesture: DragGesture.Value) {
        self.drag.translation = gesture.translation
    }
    
    private func onDragEnded(_ gesture: DragGesture.Value) {
        drag.offset = .zero
        drag.translation = nil
    }
    
    @MainActor
    private func processPositions(newPositions: [AnyHashable: CGRect]) {
        let positions = newPositions.mapValues { rect -> CGRect in
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            if proxy.direction == .normal {
                x = rect.origin.x
                y = rect.origin.y
            } else {
                x = proxy.size.width - rect.origin.x
                y = proxy.size.height - rect.origin.y
            }
            
            let width = rect.width
            let height = rect.height
            return CGRect(x: x, y: y, width: width, height: height)
        }
        
        throttlePositionsUpdate(positions)
    }
    
    @MainActor
    private func throttlePositionsUpdate(_ newPositions: [AnyHashable: CGRect]) {
        workItem?.cancel()
        let workItem = DispatchWorkItem {
            DispatchQueue.main.async {
                updatePositions(for: newPositions)
            }
        }
        self.workItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
    
    @MainActor
    private func updatePositions(for items: [AnyHashable: CGRect], threshold: CGFloat = 1.0) {
        for (id, currentRect) in items {
            if let previousRect = proxy.positions[id] {
                let deltaX = abs(currentRect.origin.x - previousRect.origin.x)
                let deltaY = abs(currentRect.origin.y - previousRect.origin.y)
                
                if deltaX > threshold || deltaY > threshold {
                    proxy.positions[id] = currentRect
                }
            } else {
                proxy.positions[id] = currentRect
            }
        }
        
        for id in proxy.positions.keys where items[id] == nil {
            proxy.positions.removeValue(forKey: id)
        }
    }
}
