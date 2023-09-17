//
//  SphericalDistanceIntersection.swift
//
//
//  Created by Daniel Sanchez on 9/16/23.
//

import Foundation
import Geodesic

func sphericalDistanceIntersection(pointA: any LLPoint, pointB: any LLPoint, distanceAC distAC: Meters, distanceBC distBC: Meters) throws -> [LatLonPoint] {
    // Refer to Section 3: Basic Calculations,
    // Article 2b: Spherical distance intersection.
    //
    // If points are too close to each other (within tolerance), the result would not be accurate.
    // Exit function.
    if pointA.coincidesWith(pointB) {
        throw GeodesicError.pointsTooClose
    }
    let a: Meters = distBC
    let b: Meters = distAC
    let c: Meters = pointA.distanceTo(pointB)
    let brgAB: Degrees = pointA.initialTrueCourseTo(pointB)
    
    let (sinAR, cosAR) = (sin(a / .sphereRadius), cos(a / .sphereRadius))
    let (sinBR, cosBR) = (sin(b / .sphereRadius), cos(b / .sphereRadius))
    let (sinCR, cosCR) = (sin(c / .sphereRadius), cos(c / .sphereRadius))
    
    let numA: Double = cosAR - cosBR * cosCR
    let denA: Double = sinBR * sinCR
    
    let numB: Double = cosBR - cosAR * cosCR
    let denB: Double = sinAR * sinCR
    
    let numC: Double = cosCR - cosAR * cosBR
    let denC: Double = sinAR * sinBR
    
    let A: Radians = acos(numA / denA)
    let B: Radians = acos(numB / denB)
    let C: Radians = acos(numC / denC)
    
    let brgAC1: Degrees = brgAB - A.deg
    let brgAC2: Degrees = brgAB + A.deg
    
    return [pointA.coordinate(atAzimuth: brgAC1, distance: b), pointA.coordinate(atAzimuth: brgAC2, distance: b)]
}
