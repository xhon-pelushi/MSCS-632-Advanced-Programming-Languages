#include "Ride.h"
#include <sstream>
#include <iomanip>

Ride::Ride(int rideID, std::string pickupLocation, std::string dropoffLocation, double distance)
    : rideID(rideID),
      pickupLocation(std::move(pickupLocation)),
      dropoffLocation(std::move(dropoffLocation)),
      distance(distance) {}

int Ride::getRideID() const { return rideID; }
const std::string& Ride::getPickupLocation() const { return pickupLocation; }
const std::string& Ride::getDropoffLocation() const { return dropoffLocation; }
double Ride::getDistance() const { return distance; }

double Ride::fare() const {
    const double baseFare = 2.00;
    const double perMile = 1.00;
    return baseFare + perMile * distance;
}

std::string Ride::rideType() const {
    return "Ride";
}

std::string Ride::rideDetails() const {
    std::ostringstream out;
    out << "[" << rideType() << " #" << rideID << "] "
        << pickupLocation << " -> " << dropoffLocation
        << " (" << std::fixed << std::setprecision(1) << distance << " mi), "
        << "fare: $" << std::fixed << std::setprecision(2) << fare();
    return out.str();
}
