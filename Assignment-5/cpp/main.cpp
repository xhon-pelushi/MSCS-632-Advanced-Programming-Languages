#include <iostream>
#include <memory>
#include <vector>
#include "Ride.h"
#include "StandardRide.h"
#include "PremiumRide.h"
#include "Driver.h"
#include "Rider.h"

int main() {
    // The main() function owns every Ride; Driver/Rider only hold non-owning
    // references so the same ride can appear on both a driver's and a
    // rider's history without copying or double-managing its lifetime.
    std::vector<std::unique_ptr<Ride>> rides;
    rides.push_back(std::make_unique<StandardRide>(101, "Maple St", "Oak Ave", 4.2));
    rides.push_back(std::make_unique<PremiumRide>(102, "Airport", "Downtown", 12.8));
    rides.push_back(std::make_unique<StandardRide>(103, "5th Ave", "Central Park", 2.5));
    rides.push_back(std::make_unique<PremiumRide>(104, "Hotel Plaza", "Convention Center", 6.0));

    std::cout << "=== Ride Sharing System (C++) ===\n\n";

    std::cout << "-- Polymorphic ride list (fare() and rideDetails()) --\n";
    for (const auto& ride : rides) {
        // Calling through a Ride* here always resolves to the correct
        // override (StandardRide vs PremiumRide) at runtime.
        std::cout << ride->rideDetails() << "\n";
    }

    Driver driver(1, "Jordan Lee", 4.9);
    driver.addRide(rides[0].get());
    driver.addRide(rides[1].get());
    driver.addRide(rides[3].get());

    Rider rider(1, "Avery Chen");
    rider.requestRide(rides[0].get());
    rider.requestRide(rides[2].get());

    std::cout << "\n-- Driver summary --\n" << driver.getDriverInfo() << "\n";
    std::cout << "\n-- Rider summary --\n" << rider.viewRides();

    return 0;
}
