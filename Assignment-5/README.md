# Assignment 5 — Class-Based Ride Sharing System

The same Ride Sharing System implemented independently in **C++** and **Pharo
Smalltalk**, demonstrating encapsulation, inheritance, and polymorphism.

## Design

- `Ride` — base class: `rideID`, `pickupLocation`, `dropoffLocation`,
  `distance`; a `fare()` method and a `rideDetails()` method.
- `StandardRide` / `PremiumRide` — subclasses that each override `fare()`
  with their own per-mile pricing.
- `Driver` — `driverID`, `name`, `rating`, and a private list of assigned
  rides reachable only through `addRide()` / `getDriverInfo()`.
- `Rider` — `riderID`, `name`, and a private list of requested rides
  reachable only through `requestRide()` / `viewRides()`.
- A demo populates a mixed list of `StandardRide`/`PremiumRide` objects and
  calls `fare()`/`rideDetails()` polymorphically through the base type.

## C++

```
cd cpp
g++ -std=c++17 -o ride_sharing Ride.cpp StandardRide.cpp PremiumRide.cpp Driver.cpp Rider.cpp main.cpp
./ride_sharing
```

## Smalltalk (Pharo)

Requires a Pharo 11 VM + image (downloadable with no install/root needed
from https://files.pharo.org/get-files/110/). Run headlessly with:

```
cd smalltalk
pharo --headless Pharo.image RideSharingSystem.st
```
