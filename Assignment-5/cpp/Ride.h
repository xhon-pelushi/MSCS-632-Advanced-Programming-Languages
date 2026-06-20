#ifndef RIDE_H
#define RIDE_H

#include <string>

class Ride {
public:
    Ride(int rideID, std::string pickupLocation, std::string dropoffLocation, double distance);
    virtual ~Ride() = default;

    int getRideID() const;
    const std::string& getPickupLocation() const;
    const std::string& getDropoffLocation() const;
    double getDistance() const;

    // Polymorphic fare calculation; each ride type prices distance differently.
    virtual double fare() const;

    // Polymorphic display of ride information, built on top of fare().
    virtual std::string rideDetails() const;

protected:
    virtual std::string rideType() const;

private:
    int rideID;
    std::string pickupLocation;
    std::string dropoffLocation;
    double distance;
};

#endif
