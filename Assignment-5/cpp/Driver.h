#ifndef DRIVER_H
#define DRIVER_H

#include <string>
#include <vector>
#include "Ride.h"

class Driver {
public:
    Driver(int driverID, std::string name, double rating);

    void addRide(Ride* ride);
    std::string getDriverInfo() const;

    int getDriverID() const;
    const std::string& getName() const;
    double getRating() const;

private:
    int driverID;
    std::string name;
    double rating;
    std::vector<Ride*> assignedRides;  // private: only addRide()/getDriverInfo() touch this
};

#endif
