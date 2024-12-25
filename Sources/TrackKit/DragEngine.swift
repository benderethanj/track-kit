import SwiftUI
import Combine

@Observable
public class DragEngine {
    var proxy: TrackProxy
    
    public init(proxy: TrackProxy) {
        self.proxy = proxy
        self.start()
    }
    
    deinit {
        self.stop()
    }
    
    public var offset: CGSize = .zero
    public var velocity: CGSize = .zero
    public var acceleration: CGSize = .zero
    public var time: Date = .now
    
    internal var translation: CGSize? = .zero
    
    private var cancellable: AnyCancellable?
    
    private func start() {
        self.cancellable = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                let overflow = self.proxy.overflow
                let friction = self.proxy.friction
                let resistance = self.proxy.resistance
                
                let now = Date()
                let dt = now.timeIntervalSince(self.time)
                self.time = now
                
                if let translation = self.translation {
                    
                    let ds = (translation - self.offset).limit(to: self.proxy.axis)
                    self.offset = translation
                    
                    let velocity = ds / dt
                    let dv: CGSize = (velocity - self.velocity).limit(to: self.proxy.axis)
                    
                    let acceleration = dv / dt
                    withAnimation {
                        self.acceleration = acceleration
                    }
                    
                } else {
                    
                    if abs(self.velocity.width) < 1 { self.velocity.width = 0 }
                    if abs(self.velocity.height) < 1 { self.velocity.height = 0 }
                    
                    withAnimation {
                        self.acceleration = .init(width: self.velocity.width, height: self.velocity.height).limit(to: self.proxy.axis) * -friction
                    }
                    
                    if self.proxy.overflow != .zero {
                        withAnimation(.bouncy) {
                            self.acceleration = .zero
                            self.velocity = .zero
                            self.proxy.offset -= overflow
                        }
                    }
                    
                }
                 
                if overflow.height < 0 {
                    self.acceleration.height = max(self.acceleration.height, 1000000 / overflow.height / resistance)
                } else if self.proxy.overflow.height > 0 {
                    self.acceleration.height = min(self.acceleration.height, 1000000 / overflow.height / resistance)
                }
                
                if overflow.width < 0 {
                    self.acceleration.width = max(self.acceleration.width, 1000000 / overflow.width / resistance)
                } else if self.proxy.overflow.width > 0 {
                    self.acceleration.width = min(self.acceleration.width, 1000000 / overflow.width / resistance)
                }
                
                self.velocity += self.acceleration * dt
                self.proxy.offset += self.velocity * dt
            }
    }
    
    private func stop() {
        self.cancellable?.cancel()
        self.cancellable = nil
    }
}
