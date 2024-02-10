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
        
        func getNextLinearDistance(distances x: [Meters], errors y: [Radians]) -> Meters? {
            if x[0] == x[1] {
                return x[0]
            } else if y[0] == y[1] {
                return nil
            } else {
                let m = (y[1] - y[0]) / (x[1] - x[0])
                let b = y[0] - m * x[0]
                return -b / m
            }
        }
        
        
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
        
        var (newCrs13, newCrs23) = (crs13, crs23)
        if sin(angle1.rad) * sin(angle2.rad) < 0 {
            if abs(angle1) > abs(angle2) {
                angle1 = (crs13 + 180) - crs12
                newCrs13 = crs13 + 180
            } else {
                angle2 = crs21 - (crs23 + 180)
                newCrs23 = crs23 + 180
            }
        }
        var intx: LatLonPoint!
        do {
            // Will return a non-nil value, will be safe to unwrap.
            intx = try sphericalDirectionIntersection(pointA: p1, pointB: p2, bearingAC: newCrs13, bearingBC: newCrs23)
        } catch {
            // If intx is unassigned, function will be exited safely. No chance of nil value after closing do block.
            throw error
        }
        
        let g13 = p1.inverse(p2: intx)
        let g23 = p2.inverse(p2: intx)
        if g13.s12 == 0 {
            return IntersectionResult(intersection: p1, input1: p1, input2: p2)
        } else if g23.s12 == 0 {
            return IntersectionResult(intersection: p2, input1: p1, input2: p2)
        }
        //
        var p1x = g13.s12 < .distanceTolerance ? p1.direct(bearing: crs13.reverse, distance: 1000).p2 : p1
        var g1x3 = p1x.inverse(p2: intx)
        var crs1x3 = g1x3.a1
        //
        var p2x = g23.s12 < .distanceTolerance ? p1.direct(bearing: crs23.reverse, distance: 1000).p2 : p2
        var g2x3 = p2x.inverse(p2: intx)
        var crs2x3 = g2x3.a1
        //
        let swapped: Bool = g2x3.s12 < g1x3.s12
        if swapped {
            swap(&p1x, &p2x)
            swap(&g1x3, &g2x3)
            swap(&crs1x3, &crs2x3)
        }
        //
        let p3a = p1x.direct(bearing: crs1x3, distance: g1x3.s12).p2
        let g2x3a = p2x.inverse(p2: p3a)
        var distArray: [Meters] = [g1x3.s12, g1x3.s12 * 1.01]
        var errArray: [Radians] = [g2x3a.a1.difference(with: crs2x3).rad, 0]
        let p3b = p1x.direct(bearing: crs1x3, distance: g1x3.s12 * 1.01).p2
        let g2x3b = p2x.inverse(p2: p3b)
        errArray[1] = g2x3b.a1.difference(with: crs2x3).rad
        var k = 0
        var err = Meters.infinity
        var p3n: LatLonPoint
        var acrs2: Degrees
        while abs(err) > .distanceTolerance && k < 10 {
            guard let d1x3 = getNextLinearDistance(distances: distArray, errors: errArray) else {
                throw GeodesicError.isCollinear
            }
            p3n = p1x.direct(bearing: crs1x3, distance: d1x3).p2
            acrs2 = p2x.inverse(p2: intx).a1
            err = p3n.inverse(p2: intx).s12
            distArray.removeFirst()
            errArray.removeFirst()
            distArray.append(d1x3)
            errArray.append(acrs2.difference(with: crs2x3).rad)
            intx = p3n
            k += 1
        }
        if abs(err) > .distanceTolerance {
            throw GeodesicError.didNotConverge
        } else {
            return IntersectionResult(intersection: intx, input1: p1, input2: p2)
        }
    }
}
