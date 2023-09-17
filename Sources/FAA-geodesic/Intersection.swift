//
//  Intersection.swift
//
//
//  Created by Daniel Sanchez on 9/10/23.
//

import Foundation
import Geodesic

struct IntersectionResult {
    let intersection: LatLonPoint
    let input1: LatLonPoint
    let input2: LatLonPoint
    
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

extension LLPoint {
    func getIntersection(azimuth a13: Double, point2 p2: any LLPoint, azimuth2 a23: Double) throws -> IntersectionResult {
        // Placeholder.
        let p1 = self
        // (1) Collinearity check.
        var (s12, crs12, crs21) = p1.inverse(p2: p2)
        print(s12, crs12, crs21)
        
        
        throw GeodesicError.didNotConverge
    }
}
