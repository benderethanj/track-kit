import SwiftUI

extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs - rhs
    }
    
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    static func * (lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
    }
    
    func limit(to axis: Axis.Set) -> Self {
        var value = self
        if !axis.contains(.vertical) {
            value.height = .zero
        }
        if !axis.contains(.horizontal) {
            value.width = .zero
        }
        return value
    }
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }
    
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    
    func limit(to axis: Axis.Set) -> Self {
        var value = self
        if !axis.contains(.vertical) {
            value.y = .zero
        }
        if !axis.contains(.horizontal) {
            value.x = .zero
        }
        return value
    }
}

func sign(_ value: Double) -> Double {
    if value == 0 { return 0 } else { return value / abs(value) }
}

precedencegroup Exponentiative {
  associativity: left
  higherThan: MultiplicationPrecedence
}

infix operator ^ : Exponentiative

public func ^ <N: BinaryInteger>(base: N, power: N) -> N {
    return N.self( pow(Double(base), Double(power)) )
}

public func ^ <N: BinaryFloatingPoint>(base: N, power: N) -> N {
    return N.self ( pow(Double(base), Double(power)) )
}

precedencegroup ExponentiativeAssignment {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator ^= : ExponentiativeAssignment

public func ^= <N: BinaryInteger>(lhs: inout N, rhs: N) {
    lhs = lhs ^ rhs
}

public func ^= <N: BinaryFloatingPoint>(lhs: inout N, rhs: N) {
    lhs = lhs ^ rhs
}
