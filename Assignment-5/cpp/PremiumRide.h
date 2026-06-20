#ifndef PREMIUM_RIDE_H
#define PREMIUM_RIDE_H

#include "Ride.h"

class PremiumRide : public Ride {
public:
    PremiumRide(int rideID, std::string pickupLocation, std::string dropoffLocation, double distance);

    double fare() const override;

protected:
    std::string rideType() const override;

private:
    static constexpr double serviceFee = 3.00;
};

#endif
