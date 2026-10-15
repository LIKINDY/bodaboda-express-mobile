import { calculateFare } from '../services/pricingService.js';
import { activeRides } from '../services/websocketService.js';

export async function estimateRideFare(req, res) {
  try {
    const { distanceKm, durationMins, vehicleType, serviceType } = req.body;

    const result = calculateFare({
      distanceKm: distanceKm || 3.5,
      durationMins: durationMins || 10,
      vehicleType: vehicleType || 'bodaboda',
      serviceType: serviceType || 'ride'
    });

    res.json({
      success: true,
      ...result
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function getRideDetails(req, res) {
  try {
    const { rideId } = req.params;
    const ride = activeRides.get(rideId);

    if (!ride) {
      return res.status(404).json({ success: false, message: 'Safari haikupatikana' });
    }

    res.json({
      success: true,
      ride: {
        rideId: ride.rideId,
        status: ride.status,
        fare: ride.fare,
        otpPin: ride.otpPin,
        pickupAddress: ride.pickupAddress,
        destinationAddress: ride.destinationAddress,
        assignedDriver: ride.assignedDriver,
        createdAt: ride.createdAt
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function cancelRide(req, res) {
  try {
    const { rideId } = req.params;
    const { reason, driverDistanceCoveredKm } = req.body;

    const ride = activeRides.get(rideId);
    let cancellationFee = 0;

    // In accordance with app policy: if cancelled after driver moves > 0.5km, charge 1500 TZS fee
    if (driverDistanceCoveredKm && Number(driverDistanceCoveredKm) > 0.5) {
      cancellationFee = 1500;
    }

    if (ride) {
      ride.status = 'cancelled';
      ride.cancellationReason = reason || 'Mteja ameghairi safari';
      ride.cancellationFee = cancellationFee;
    }

    res.json({
      success: true,
      message: 'Safari imeghairiwa kwa mafanikio',
      cancellationFee,
      currency: 'TZS',
      note: cancellationFee > 0 ? 'Fidia ya TZS 1,500 imewekwa kwenye deni la mteja kwa ajili ya dereva.' : 'Hakuna ada ya kughairi iliyotozwa.'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function getRideHistory(req, res) {
  try {
    // Demo history items
    const sampleHistory = [
      {
        rideId: 'TRIP-8841',
        date: '2026-10-14 14:20',
        pickup: 'Kariakoo Msimbazi',
        destination: 'Posta Mpya, Azikiwe St',
        vehicleType: 'bodaboda',
        fare: 3500,
        driverName: 'Juma Shabani',
        status: 'completed'
      },
      {
        rideId: 'TRIP-7622',
        date: '2026-10-12 09:15',
        pickup: 'Mwenge Bus Stand',
        destination: 'Sinza Mori',
        vehicleType: 'bajaji',
        fare: 4500,
        driverName: 'Hamisi Bakari',
        status: 'completed'
      }
    ];

    res.json({
      success: true,
      rides: sampleHistory
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}
