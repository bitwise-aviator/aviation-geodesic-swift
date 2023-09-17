//
// IsOnGeodesic.swift
//
//
//  Created by Daniel Sanchez on 9/13/23.
//

import Foundation
import Geodesic

enum LengthCode: Int {
    case noExtension = 0
    case extendsBeyondEnd = 1
    case extendsBeyondStartAndEnd = 2
    
}

extension LLPoint {
    func isOnGeodesic(point1 p1: any LLPoint, point2 p2: any LLPoint, extendGeodesic extent: LengthCode = .noExtension) -> Bool {
        // Refer to Section 3: Basic Calculations,
        // Article 5: Determine if point lies on geodesic.
        return false
    }
}

