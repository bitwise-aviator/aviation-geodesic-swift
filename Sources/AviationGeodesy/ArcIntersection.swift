//
//  File.swift
//  
//
//  Created by Daniel Sanchez on 9/16/23.
//

import Foundation
import Geodesic

public extension Arc {
    func intersectionsWith(arc arc2: Arc) throws -> [LatLonPoint] {
        let (dist12, crs12, _) = self.center.distanceAndCoursesTo(arc2.center)
        if self.center.coincidesWith(arc2.center) {
            // Arcs are concentric within tolerance. Infinite or null solutions.
            throw GeodesicError.arcsAreConcentric
        } else if self.radius + arc2.radius - dist12 + .distanceTolerance < 0 {
            // No intersections: arcs are too far apart.
            throw GeodesicError.arcsTooFarApart
        } else if abs(self.radius - arc2.radius) > dist12 {
            // No intersections: larger arc fully contains smaller one.
            throw GeodesicError.arcContainedByAnother
        } else if abs(self.radius - arc2.radius - dist12) <= .distanceTolerance {
            // Tangential arcs: one solution is expected.
            let intersection = self.center.coordinate(atAzimuth: crs12, distance: dist12)
            // Checking if point is on arcs (will always be true if arcs are full circles)
            if self.includesPoint(intersection) && arc2.includesPoint(intersection) {
                return [intersection]
            } else {
                throw GeodesicError.noSolutionsOnArcSection
            }
        }
        // All other scenarios: two solutions expected for full circles.
        guard let initialSolutions = try? sphericalDistanceIntersection(pointA: self.center, pointB: arc2.center, distanceAC: self.radius, distanceBC: arc2.radius) else {
            throw GeodesicError.arcsAreConcentric
        }
        var solutions = [LatLonPoint]()
        let kMax = 20 // Maximum iterations
        for sol in initialSolutions {
            var k: Int = 0
            var pt: LatLonPoint = sol
            var crs2x = arc2.center.initialTrueCourseTo(pt)
            pt = arc2.pointAtAzimuth(crs2x)
            var (dist1x, crs1x, _) = self.center.inverse(p2: pt)
            var error: Meters = self.radius - dist1x
            var errArray: [Meters] = [0, error]
            var crsArray: [Degrees] = [0, crs1x]
            while k <= kMax && (abs(errArray[1]) > .distanceTolerance) {
                pt = self.pointAtAzimuth(crs1x)
                crs2x = arc2.center.initialTrueCourseTo(pt)
                pt = arc2.pointAtAzimuth(crs2x)
                (dist1x, crs1x, _) = self.center.inverse(p2: pt)
                error = self.radius - dist1x
                crsArray[0] = crsArray[1]
                errArray[0] = errArray[1]
                crsArray[1] = crs1x
                errArray[1] = error
                
                guard let newCrs1x = try? Double.findLinearRoot(values: crsArray, errors: errArray) else {
                    throw MathError.badInput
                }
                crs1x = newCrs1x
                k += 1
            }
            if k > kMax {
                throw GeodesicError.didNotConverge
            }
            solutions.append(pt)
            //
            k = 0
        }
        let filteredSolutions = solutions.filter({ self.includesPoint($0) && arc2.includesPoint($0) })
        if filteredSolutions.isEmpty {
            throw GeodesicError.noSolutionsOnArcSection
        }
        return filteredSolutions
    }
}
