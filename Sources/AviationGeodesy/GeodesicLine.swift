//
//  GeodesicLine.swift
//
//
//  Created by Daniel Sanchez on 9/17/23.
//

import Foundation
import Geodesic

public struct GeodesicLine {
    public let point: any LLPoint
    public let bearing: Degrees
    public let endPoint: (any LLPoint)?
    public let length: Meters?
    public let extent: LengthCode
    public var isFinite: Bool {
        extent == .noExtension
    }
    
    public init?(from p1: any LLPoint, to p2: any LLPoint, extent: LengthCode = .noExtension) {
        // Finite geodesic, defaults to no extension.
        guard !p1.coincidesWith(p2) else {
            return nil
        }
        point = p1
        endPoint = p2
        (length, bearing, _) = p1.inverse(p2: p2)
        self.extent = extent
    }
    
    public init?(from p1: any LLPoint, along brg: Degrees, for dist: Meters, extent: LengthCode = .noExtension) {
        // Finite geodesic, defaults to no extension.
        guard dist > 0 else {
            return nil
        }
        point = p1
        bearing = brg
        endPoint = p1.coordinate(atAzimuth: brg, distance: dist)
        length = dist
        self.extent = extent
    }
    
    public init?(from p1: any LLPoint, along brg: Degrees, extent: LengthCode = .extendsBeyondEnd) {
        // Infinite geodesic, default to only extending along base azimuth.
        guard extent != .noExtension else {
            print("Infinite geodesic cannot be handled as finite.")
            return nil
        }
        point = p1
        bearing = brg
        endPoint = nil
        length = nil
        self.extent = extent
    }
}
