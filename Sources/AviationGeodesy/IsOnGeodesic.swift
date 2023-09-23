//
// IsOnGeodesic.swift
//
//
//  Created by Daniel Sanchez on 9/13/23.
//

import Foundation
import Geodesic

public enum LengthCode: Int {
    case noExtension = 0
    case extendsBeyondEnd = 1
    case extendsBeyondStartAndEnd = 2
    
}

public extension GeodesicLine {
    func containsPoint(_ pt: any LLPoint, ignoreReverse: Bool = false) -> Bool {
        // Refer to Section 3: Basic Calculations,
        // Article 5: Determine if point lies on geodesic.
        let (crs12, dist12) = (self.bearing, self.length)
        let dist13 = self.point.distanceTo(pt)
        let testPt = self.point.coordinate(atAzimuth: crs12, distance: dist13)
        if pt.coincidesWith(testPt) {
            if !self.isFinite || abs(dist13 - dist12!) <= .distanceTolerance {
                return true
            }
        } else if ignoreReverse || self.extent != .extendsBeyondStartAndEnd {
            // If does not coincide and not searching backwards, geodesic does not contain point.
            return false
        }
        let testPt2 = self.point.coordinate(atAzimuth: self.bearing.reverse, distance: dist13)
        return pt.coincidesWith(testPt2)
        
        
    }
}

public extension LLPoint {
    func isOnGeodesic(_ geodesic: GeodesicLine, ignoreReverse: Bool = false) -> Bool {
        // Wrapper of function above.
        return geodesic.containsPoint(self, ignoreReverse: ignoreReverse)
    }
}

