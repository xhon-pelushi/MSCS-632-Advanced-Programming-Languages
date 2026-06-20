#include "PremiumRide.h"

PremiumRide::PremiumRide(int rideID, std::string pickupLocation, std::string dropoffLocation, double distance)
    : Ride(rideID, std::move(pickupLocation), std::move(dropoffLocation), distance) {}

double PremiumRide::fare() const {
    const double baseFare = 5.00;
    const double perMile = 2.50;
    return serviceFee + baseFare + perMile * getDistance();
}

std::string PremiumRide::rideType() const {
    return "PremiumRide";
}
