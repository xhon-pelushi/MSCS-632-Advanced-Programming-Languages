#include "Rider.h"
#include <sstream>

Rider::Rider(int riderID, std::string name)
    : riderID(riderID), name(std::move(name)) {}

void Rider::requestRide(Ride* ride) {
    requestedRides.push_back(ride);
}

int Rider::getRiderID() const { return riderID; }
const std::string& Rider::getName() const { return name; }

std::string Rider::viewRides() const {
    std::ostringstream out;
    out << "Rider #" << riderID << " " << name
        << " - " << requestedRides.size() << " ride(s) requested:\n";
    for (const Ride* ride : requestedRides) {
        out << "    " << ride->rideDetails() << "\n";  // polymorphic: each ride type formats itself
    }
    return out.str();
}
