// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

typealias Meters = Double

extension Double {
    // WGS-84 ellipsoid constants (Karney, 2013)
    static let a: Meters = 6_378_137.0
    static let f: Meters = 1/298.257223563
    static let b: Meters = 6_356_752.314245
    static let sphereRadius: Meters = sqrt(a * b)
}
