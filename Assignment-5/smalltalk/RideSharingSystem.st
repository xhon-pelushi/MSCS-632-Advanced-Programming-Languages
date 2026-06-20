"Ride Sharing System - Pharo Smalltalk
Run headlessly with:
    pharo --headless Pharo.image RideSharingSystem.st
"

"==================== Ride (base class) ===================="
Object subclass: #Ride
    instanceVariableNames: 'rideID pickupLocation dropoffLocation distance'
    classVariableNames: ''
    package: 'RideSharing'.

Ride class compile: 'id: anID pickup: aPickup dropoff: aDropoff distance: aDistance
    | r |
    r := self new.
    r setId: anID pickup: aPickup dropoff: aDropoff distance: aDistance.
    ^ r'.

"Encapsulation: rideID/pickupLocation/dropoffLocation/distance are private
instance variables. Outside code can only read them through these accessor
methods, and can only set them through setId:pickup:dropoff:distance:."
Ride compile: 'setId: anID pickup: aPickup dropoff: aDropoff distance: aDistance
    rideID := anID.
    pickupLocation := aPickup.
    dropoffLocation := aDropoff.
    distance := aDistance'.

Ride compile: 'rideID
    ^ rideID'.

Ride compile: 'pickupLocation
    ^ pickupLocation'.

Ride compile: 'dropoffLocation
    ^ dropoffLocation'.

Ride compile: 'distance
    ^ distance'.

"Base fare formula; StandardRide and PremiumRide override this."
Ride compile: 'fare
    ^ (2.00 + (1.00 * distance)) roundTo: 0.01'.

"Overridden by each subclass so rideDetails stays polymorphic."
Ride compile: 'rideType
    ^ ''Ride'''.

Ride compile: 'rideDetails
    ^ ''['', self rideType, '' #'', rideID printString, ''] '',
        pickupLocation, '' -> '', dropoffLocation,
        '' ('', distance printString, '' mi), fare: $'', self fare printString'.

"==================== StandardRide (subclass) ===================="
Ride subclass: #StandardRide
    instanceVariableNames: ''
    classVariableNames: ''
    package: 'RideSharing'.

StandardRide compile: 'fare
    ^ (2.50 + (1.25 * self distance)) roundTo: 0.01'.

StandardRide compile: 'rideType
    ^ ''StandardRide'''.

"==================== PremiumRide (subclass) ===================="
Ride subclass: #PremiumRide
    instanceVariableNames: ''
    classVariableNames: ''
    package: 'RideSharing'.

PremiumRide compile: 'fare
    ^ (3.00 + 5.00 + (2.50 * self distance)) roundTo: 0.01'.

PremiumRide compile: 'rideType
    ^ ''PremiumRide'''.

"==================== Driver ===================="
Object subclass: #Driver
    instanceVariableNames: 'driverID driverName rating assignedRides'
    classVariableNames: ''
    package: 'RideSharing'.

Driver class compile: 'id: anID name: aName rating: aRating
    | d |
    d := self new.
    d setId: anID name: aName rating: aRating.
    ^ d'.

"Encapsulation: assignedRides is private; the only ways to affect it from
outside this class are addRide: (to grow it) and getDriverInfo (to read a
summary of it). There is no accessor that hands out the raw collection."
Driver compile: 'setId: anID name: aName rating: aRating
    driverID := anID.
    driverName := aName.
    rating := aRating.
    assignedRides := OrderedCollection new'.

Driver compile: 'addRide: aRide
    assignedRides add: aRide'.

Driver compile: 'getDriverInfo
    | out total nl |
    nl := String with: Character lf.
    total := 0.
    out := WriteStream on: String new.
    out nextPutAll: ''Driver #'', driverID printString, '' '', driverName,
        '' (rating '', rating printString, '') - '',
        assignedRides size printString, '' ride(s) completed:'', nl.
    assignedRides do: [ :r |
        out nextPutAll: ''    '', r rideDetails, nl.
        total := total + r fare ].
    out nextPutAll: ''    Total earnings: $'', (total roundTo: 0.01) printString.
    ^ out contents'.

"==================== Rider ===================="
Object subclass: #Rider
    instanceVariableNames: 'riderID riderName requestedRides'
    classVariableNames: ''
    package: 'RideSharing'.

Rider class compile: 'id: anID name: aName
    | r |
    r := self new.
    r setId: anID name: aName.
    ^ r'.

"Encapsulation: requestedRides is private; reachable only via requestRide:
and viewRides, exactly like Driver''s assignedRides above."
Rider compile: 'setId: anID name: aName
    riderID := anID.
    riderName := aName.
    requestedRides := OrderedCollection new'.

Rider compile: 'requestRide: aRide
    requestedRides add: aRide'.

Rider compile: 'viewRides
    | out nl |
    nl := String with: Character lf.
    out := WriteStream on: String new.
    out nextPutAll: ''Rider #'', riderID printString, '' '', riderName,
        '' - '', requestedRides size printString, '' ride(s) requested:'', nl.
    requestedRides do: [ :r | out nextPutAll: ''    '', r rideDetails, nl ].
    ^ out contents'.

"==================== Demo ===================="
[ | rides driver rider |
rides := OrderedCollection new.
rides add: (StandardRide id: 101 pickup: 'Maple St' dropoff: 'Oak Ave' distance: 4.2).
rides add: (PremiumRide id: 102 pickup: 'Airport' dropoff: 'Downtown' distance: 12.8).
rides add: (StandardRide id: 103 pickup: '5th Ave' dropoff: 'Central Park' distance: 2.5).
rides add: (PremiumRide id: 104 pickup: 'Hotel Plaza' dropoff: 'Convention Center' distance: 6.0).

Transcript show: '=== Ride Sharing System (Pharo Smalltalk) ==='; cr; cr.

Transcript show: '-- Polymorphic ride list (fare and rideDetails) --'; cr.
rides do: [ :r | Transcript show: r rideDetails; cr ].

driver := Driver id: 1 name: 'Jordan Lee' rating: 4.9.
driver addRide: (rides at: 1).
driver addRide: (rides at: 2).
driver addRide: (rides at: 4).

rider := Rider id: 1 name: 'Avery Chen'.
rider requestRide: (rides at: 1).
rider requestRide: (rides at: 3).

Transcript cr; show: '-- Driver summary --'; cr.
Transcript show: driver getDriverInfo; cr.

Transcript cr; show: '-- Rider summary --'; cr.
Transcript show: rider viewRides.
] value.

Smalltalk snapshot: false andQuit: true.
