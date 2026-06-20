#include "Driver.h"
#include <sstream>
#include <iomanip>

Driver::Driver(int driverID, std::string name, double rating)
    : driverID(driverID), name(std::move(name)), rating(rating) {}

void Driver::addRide(Ride* ride) {
    assignedRides.push_back(ride);
}

int Driver::getDriverID() const { return driverID; }
const std::string& Driver::getName() const { return name; }
double Driver::getRating() const { return rating; }

std::string Driver::getDriverInfo() const {
    std::ostringstream out;
    out << "Driver #" << driverID << " " << name
        << " (rating " << std::fixed << std::setprecision(1) << rating << ") - "
        << assignedRides.size() << " ride(s) completed:\n";

    double totalEarnings = 0.0;
    for (const Ride* ride : assignedRides) {
        out << "    " << ride->rideDetails() << "\n";
        totalEarnings += ride->fare();  // polymorphic call: each ride type prices itself
    }
    out << "    Total earnings: $" << std::fixed << std::setprecision(2) << totalEarnings;
    return out.str();
}
