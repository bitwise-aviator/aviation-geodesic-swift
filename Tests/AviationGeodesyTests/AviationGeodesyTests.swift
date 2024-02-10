import XCTest
@testable import AviationGeodesy
import Geodesic

final class AviationGeodesyTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testInverse() throws {
        Geodesic.useCompassAzimuths = true
        let p1 = LatLonPoint(latitude: 47, longitude: -80)
        let p2 = LatLonPoint(latitude: 48, longitude: -80)
        print(p1.inverse(p2: p2))
    }
    
    func testSphericalDirectionIntersection() throws {
        Geodesic.useCompassAzimuths = true
        let p1 = LatLonPoint(latitude: 33, longitude: -82)
        let p2 = LatLonPoint(latitude: 34, longitude: -83)
        let x = try? sphericalDirectionIntersection(pointA: p1, pointB: p2, bearingAC: 24, bearingBC: 78)
        print("//")
        let y = try? sphericalDirectionIntersection(pointA: p1, pointB: p2, bearingAC: 148, bearingBC: 143)
        print("//")
        let z = try? sphericalDirectionIntersection(pointA: p1, pointB: p2, bearingAC: 24, bearingBC: 258)
        print("//")
        print(x)
        print(y)
        print(z)
    }
    
    func testArcIntersection() throws {
        Geodesic.useCompassAzimuths = true
        let a1 = Arc(center: LatLonPoint(latitude: 33, longitude: -82), radius: 100000)
        let a2 = Arc(center: LatLonPoint(latitude: 34, longitude: -83), radius: 200000)
        do {
            let x = try a1.intersectionsWith(arc: a2)
            print(x)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func testIntersection() throws {
        Geodesic.useCompassAzimuths = true
        let l1 = GeodesicLine(from: LatLonPoint(latitude: 33, longitude: -82), along: 68.36)!
        let l2 = GeodesicLine(from: LatLonPoint(latitude: 34, longitude: -83), along: 111.29)!
        guard let res = try? l1.getIntersection(with: l2) else {
            print("nil")
            return
        }
        print(res.intersection)
        print(res.a13, res.a23)
        
    }
}
