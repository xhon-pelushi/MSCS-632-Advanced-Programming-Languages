#ifndef STANDARD_RIDE_H
#define STANDARD_RIDE_H

#include "Ride.h"

class StandardRide : public Ride {
public:
    StandardRide(int rideID, std::string pickupLocation, std::string dropoffLocation, double distance);

    double fare() const override;

protected:
    std::string rideType() const override;
};

#endif
