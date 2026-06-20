#include "StandardRide.h"

StandardRide::StandardRide(int rideID, std::string pickupLocation, std::string dropoffLocation, double distance)
    : Ride(rideID, std::move(pickupLocation), std::move(dropoffLocation), distance) {}

double StandardRide::fare() const {
    const double baseFare = 2.50;
    const double perMile = 1.25;
    return baseFare + perMile * getDistance();
}

std::string StandardRide::rideType() const {
    return "StandardRide";
}
