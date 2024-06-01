//
//  AviationGeodesic.swift
//
//
//  Created by Daniel Sanchez on 9/10/23.
//

import Foundation
import Geodesic

public typealias Meters = Double
public typealias Feet = Double
public typealias Degrees = Double
public typealias Radians = Double

public enum Direction {
    case left, right
}

public enum ArcDirection {
    case clockWise, counterClockWise
}

struct InverseResult {
    
}

extension Double {
    // WGS-84 ellipsoid constants (Karney, 2013)
    static let a: Meters = 6_378_137.0
    static let f: Meters = 1/298.257223563
    static let b: Meters = 6_356_752.314245
    static let sphereRadius: Meters = sqrt(a * b)
    // Convenience functions
    static let distanceTolerance: Meters = 0.01
    static let bearingTolerance: Degrees = 0.002 // FAA says 0.002 arc seconds, but that is extremely narrow and inconsistent with other references. We will assume +/-0.002 degrees and seek clarification.
    
    // Algorithm to determine linear roots. Refer to Section 3, article 1.
    static func findLinearRoot(values x: [Double], errors y: [Double]) throws -> Double {
        guard x.count == 2, y.count == 2 else {
            throw MathError.badInput
        }
        if x[0] == x[1] {
            return x[0]
        } else if y[0] == y[1] {
            if y[0] == 0 {
                return x[0]
            } else {
                return 0.5 * (x[0] + x[1])
            }
        } else {
            return -y[0] * (x[1] - x[0]) / (y[1] - y[0]) + x[0]
        }
    }
}

extension Degrees {
    var rad: Radians {
        return self * .pi / 180
    }
    
    public var inCompassForm: Double {
        var deg = self
        while deg < 0 {
            deg += 360
        }
        return deg.truncatingRemainder(dividingBy: 360)
    }
    
    public var reverse: Degrees {
        (self + 180).truncatingRemainder(dividingBy: 360)
    }
    
    /// Calculates difference between two azimuths (self - B).
    ///
    /// Reference: Section 2: Useful Functions, 3: Signed azimuth difference.
    /// Expanded to force turn directions if desired.
    /// - Parameters:
    ///   - B: The second azimuth to be compared.
    ///   - forceDirection: If left as nil, will return difference in range [-180, +180). Else, it will guarantee a positive value (right turns) or a negative value (left turns).
    /// - Returns: Difference between the two azimuths, in the appropriate range.
    public func difference(with B: Degrees, forceDirection: Direction? = nil) -> Degrees {
        var diff: Degrees = self - B
        switch forceDirection {
        case .none:
            // Will return in range [-180, +180)
            while diff < -180 {
                diff += 360
            }
            while diff >= 180 {
                diff -= 360
            }
        case .left:
            // Will return in range (-360, 0]
            while diff <= -360 {
                diff += 360
            }
            while diff > 0 {
                diff -= 360
            }
        case .right:
            // Will return in range [0, +360)
            while diff < 0 {
                diff += 360
            }
            while diff >= 360 {
                diff -= 360
            }
        }
        return diff
    }
}

extension Radians {
    var deg: Degrees {
        return self * 180 / .pi
    }
}


public extension LLPoint {
    /// Shorthand, customized method to call the inverse function.
    /// - Parameters:
    ///   - p2: The destination point (Point 2).
    ///   - a2isReversed: Set to true if a2 should be the forward course from Point 2 to Point 1.
    /// - Returns: Distance and azimuths between Point 1 and Point 2
    func inverse(p2: any LLPoint, a2isReversed: Bool = false) -> (s12: Meters, a1: Degrees, a2: Degrees) {
        if !a2isReversed {
            return self.distanceAndCoursesTo(p2)
        } else {
            let results = self.distanceAndCoursesTo(p2)
            return (s12: results.s12, a1: results.a1, a2: results.a2.reverse)
        }
    }
    
    func direct(bearing a1: Degrees, distance s12: Meters) -> (p2: LatLonPoint, a2: Degrees) {
        let result = self.coordinateAndForwardAzimuth(atAzimuth: a1, distance: s12)
        return (p2: result.B, a2: result.a2)
    }
    
    func coincidesWith(_ p2: any LLPoint) -> Bool {
        self.distanceTo(p2) <= .distanceTolerance
    }
}
