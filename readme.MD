This is a Swift-based interpretation of the U.S. Federal Aviation Administration's **Order 8260.3E: United States Standard for Terminal Instrument Procedures (TERPS)**'s geodesic standard (Appendix F). While most Swift code is intended for Apple/iOS use, this library is intended to function with open-source components (namely, the open-source Foundation package and other libraries) and is not limited to Apple devices.

**This library has not been developed by/with, nor endorsed by the Federal Aviation Administration.**

The latest version of FAA Order 8260.3E (Change 1, effective 3/8/22) is available [here](https://www.faa.gov/documentLibrary/media/Order/Order_82603E_CHG-01_Consolidated.pdf).

Caution: the FAA uses Vincenty's (1975) formulae for determining the direct and inverse geodesic problems. This package uses Karney's (2013) algorithms through the GeographicLib library due to their improved accuracy and lower computational cost.

## Progress
These are the functions I have developed so far and those that are pending. I am not following the Order's sequence in choosing when to develop each.

### Section 2: Useful Functions
- 1: Calculate angular arc extent - **Not started**
- 2: Convert Lat/Lon to ECEF - **Not started**
- 3: Signed azimuth difference - **Done**
- 4: Approximate fixed radius arc length - **Not started**

### Section 3: Useful Functions
- 1: Linear Root Finder - **Done**
- 2a: Spherical direction intersection - **Done**
- 2b: Spherical distance intersection - **Done**
- 2c: Spherical tangent point - **Not started**
- 4: Geodesic oriented at specific angle - **Not started**
- 5: Determine if point lies on geodesic - **Done**
- 6: Determine if point lies on arc - **Done**
... to be continued.
