/**
 * Fare Calculation Service for Bodaboda & Bajaji
 * Rates in Tanzanian Shillings (TZS)
 */
export function calculateFare({ distanceKm = 1.0, durationMins = 5, vehicleType = 'bodaboda', serviceType = 'ride' }) {
  const km = Math.max(0.5, Number(distanceKm));
  const mins = Math.max(1, Number(durationMins));

  let baseFare = 1000;
  let perKmRate = 700;
  let perMinRate = 50;
  let minFare = 1500;

  if (vehicleType.toLowerCase() === 'bajaji') {
    baseFare = 1500;
    perKmRate = 1000;
    perMinRate = 80;
    minFare = 2500;
  }

  // Delivery surcharge for goods handling
  const deliverySurcharge = serviceType === 'delivery' ? 500 : 0;

  let total = baseFare + (km * perKmRate) + (mins * perMinRate) + deliverySurcharge;

  // Round up to nearest 100 TZS for clean payment
  total = Math.ceil(total / 100) * 100;

  // Enforce minimum fare
  const finalFare = Math.max(minFare, total);

  return {
    fare: finalFare,
    currency: 'TZS',
    breakdown: {
      baseFare,
      distanceKm: km,
      distanceCost: Math.round(km * perKmRate),
      durationMins: mins,
      timeCost: Math.round(mins * perMinRate),
      deliverySurcharge,
      vehicleType,
      serviceType
    }
  };
}
