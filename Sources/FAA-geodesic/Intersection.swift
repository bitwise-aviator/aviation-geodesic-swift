//
//  Intersection.swift
//
//
//  Created by Daniel Sanchez on 9/10/23.
//

import Foundation
import Geodesic

public struct IntersectionResult {
    let intersection: any LLPoint
    let input1: any LLPoint
    let input2: any LLPoint
    
    var a13: Double {
        input1.initialTrueCourseTo(intersection)
    }
    
    var a31: Double {
        intersection.initialTrueCourseTo(input1)
    }
    
    var a23: Double {
        input2.initialTrueCourseTo(intersection)
    }
    
    var a32: Double {
        intersection.initialTrueCourseTo(input2)
    }
    
    var s13: Double {
        input1.distanceTo(intersection)
    }
    
    var s23: Double {
        input2.distanceTo(intersection)
    }
}

public extension GeodesicLine {
    func getIntersection(with l2: GeodesicLine) throws -> IntersectionResult {
        let l1 = self
        let (p1, p2) = (l1.point, l2.point)
        let (dist12, crs12, crs21) = p1.inverse(p2: p2, a2isReversed: true)
        let (crs13, crs23) = (l1.bearing, l2.bearing)
        // (1) Collinearity check.
        if p1.isOnGeodesic(l2, ignoreReverse: true) && p2.isOnGeodesic(l1, ignoreReverse: true) {
            throw GeodesicError.isCollinear
        } else if p1.isOnGeodesic(l2, ignoreReverse: true) {
            return IntersectionResult(intersection: p1, input1: p1, input2: p2)
        } else if p2.isOnGeodesic(l1, ignoreReverse: true) {
            return IntersectionResult(intersection: p2, input1: p1, input2: p2)
        }
        var angle1: Degrees = crs12.difference(with: crs13)
        var angle2: Degrees = crs21.difference(with: crs23)
        // These steps are a bit strange. Will revisit.
        if sin(angle1.rad) * sin(angle2.rad) < 0 {
            if abs(angle1) > abs(angle2) {
                angle1 = (crs13 + 180) - crs12
            } else {
                angle2 = crs21 - (crs23 + 180)
            }
        }
        
        
        
        throw GeodesicError.didNotConverge
    }
}
