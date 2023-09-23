//
//  Arc.swift
//
//
//  Created by Daniel Sanchez on 9/16/23.
//

import Foundation
import Geodesic

public struct Arc {
    public let center: any LLPoint
    public let radius: Meters
    public let isFullCircle: Bool
    public let startingRadial: Degrees?
    public let endingRadial: Degrees?
    public let arcDirection: ArcDirection?
    
    public init(center: any LLPoint, radius: Meters) {
        self.center = center
        self.radius = radius
        startingRadial = nil
        endingRadial = nil
        arcDirection = nil
        isFullCircle = true
    }
    
    public init(center: any LLPoint, radius: Meters, from startRadial: Degrees, turning direction: ArcDirection, to endRadial: Degrees) {
        self.center = center
        self.radius = radius
        startingRadial = startRadial
        endingRadial = endRadial
        arcDirection = direction
        isFullCircle = false
    }
    
    public func containsAzimuth(_ azimuth: Degrees) -> Bool {
        if isFullCircle {
            return true
        }
        let radial1 = arcDirection == .clockWise ? startingRadial!.inCompassForm : endingRadial!.inCompassForm
        let radial2 = arcDirection == .clockWise ? endingRadial!.inCompassForm : startingRadial!.inCompassForm
        if radial2 > radial1 {
            let range = radial1...radial2
            return range.contains(azimuth)
        } else {
            let range1 = radial1...360
            let range2 = 0...radial2
            return range1.contains(azimuth) || range2.contains(azimuth)
        }
    }
    
    public func pointAtAzimuth(_ azimuth: Degrees) -> LatLonPoint {
        self.center.coordinate(atAzimuth: azimuth, distance: self.radius)
    }
    
    public func includesPoint(_ point: any LLPoint) -> Bool {
        guard abs(self.center.distanceTo(point) - self.radius) <= .distanceTolerance else {
            return false
        }
        let testAzimuth = self.center.initialTrueCourseTo(point)
        for i in [0, -.bearingTolerance, .bearingTolerance] {
            if self.containsAzimuth(testAzimuth + i) {
                return true
            }
        }
        return false
    }
}
