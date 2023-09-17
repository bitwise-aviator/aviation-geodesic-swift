//
//  ArcTangentToTwoGeodesics.swift
//
//
//  Created by Daniel Sanchez on 9/17/23.
//

import Foundation
import Geodesic

public extension Arc {
    static func tangentTo(l1: GeodesicLine, l2: GeodesicLine, radius r: Meters) -> Arc? {
        // This function will yield an arc that is tangent to two geodics with a fixed radius. Turn direction and actual tangent points cannot be set for this method without over-constraining the solution.
        return nil
    }
}
