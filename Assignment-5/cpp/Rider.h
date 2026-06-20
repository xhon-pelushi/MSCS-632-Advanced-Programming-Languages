#ifndef RIDER_H
#define RIDER_H

#include <string>
#include <vector>
#include "Ride.h"

class Rider {
public:
    Rider(int riderID, std::string name);

    void requestRide(Ride* ride);
    std::string viewRides() const;

    int getRiderID() const;
    const std::string& getName() const;

private:
    int riderID;
    std::string name;
    std::vector<Ride*> requestedRides;  // private: only requestRide()/viewRides() touch this
};

#endif
