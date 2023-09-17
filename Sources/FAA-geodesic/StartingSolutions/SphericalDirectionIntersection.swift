//
//  SphericalDirectionIntersection.swift
//
//
//  Created by Daniel Sanchez on 9/16/23.
//

import Foundation
import Geodesic

func sphericalDirectionIntersection(pointA: any LLPoint, pointB: any LLPoint, bearingAC brgAC: Degrees, bearingBC brgBC: Degrees) throws -> LatLonPoint {
    // Refer to Section 3: Basic Calculations,
    // Article 2a: Spherical direction intersection.
    //
    // If points are too close to each other (within tolerance), the result would not be accurate.
    // Exit function.
    if pointA.coincidesWith(pointB) {
        throw GeodesicError.pointsTooClose
    }
    // Iterates over a combination of base/reciprocal azimuths. It will determine that the point pairs with the lowest distance between them is the result.
    var result: LatLonPoint?
    var distance: Meters?
    for (brg1, brg2) in [(brgAC, brgBC), (brgAC.reverse, brgBC), (brgAC, brgBC.reverse), (brgAC.reverse, brgBC.reverse)] {
        let (c, brgAB, brgBA) = pointA.inverse(p2: pointB, a2isReversed: true)
        // Using normalized angles to force usage of the smallest angle.
        let A: Degrees = abs(brgAB.difference(with: brg1))
        let B: Degrees = abs(brgBA.difference(with: brg2))
        let radA: Radians = A.rad
        let radB: Radians = B.rad
        let (sinA, cosA) = (sin(radA), cos(radA))
        let (sinB, cosB) = (sin(radB), cos(radB))
        
        let C: Radians = acos(-(cosA * cosB) + sinA * sinB * cos(c / .sphereRadius) )
        let (sinC, cosC) = (sin(C), cos(C))
        
        // Handle cases where a zero division would result. This behavior will occur if the input geodesics are collinear.
        guard sinA != 0, sinB != 0, sinC != 0 else {
            throw GeometryError.willCauseDivisionByZero
        }
        
        let aNum = cosA + cosB * cosC
        let aDen = sinB * sinC
        
        let a: Meters = .sphereRadius * acos(aNum / aDen)
        
        let bNum = cosB + cosA * cosC
        let bDen = sinA * sinC
        
        let b: Meters = .sphereRadius * acos(bNum / bDen)
        
        let newDistance = pointA.direct(bearing: brg1, distance: b).p2.distanceTo(pointB.direct(bearing: brg2, distance: a).p2)
        if distance == nil || newDistance < distance! {
            distance = newDistance
            result = pointA.direct(bearing: brg1, distance: b).p2
        }
    }
    return result!
}
