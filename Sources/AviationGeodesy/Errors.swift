//
//  Errors.swift
//
//
//  Created by Daniel Sanchez on 9/16/23.
//

import Foundation

enum GeodesicError: Error {
    case didNotConverge
    case isCollinear
    case pointsTooClose
    case arcsTooFarApart
    case arcContainedByAnother
    case noSolutionsOnArcSection
    case arcsAreConcentric
    case other
}

enum GeometryError: Error {
    case willCauseDivisionByZero
}

enum MathError: Error {
    case badInput
}
