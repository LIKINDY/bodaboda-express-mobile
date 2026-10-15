export async function toggleDriverStatus(req, res) {
  try {
    const { driverId, isOnline } = req.body;

    res.json({
      success: true,
      driverId,
      status: isOnline ? 'online' : 'offline',
      message: isOnline ? 'Uko ONLINE. Unaweza kupokea maombi ya safari sasa.' : 'Uko OFFLINE. Huwezi kupokea maombi.'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function getDriverEarnings(req, res) {
  try {
    res.json({
      success: true,
      currency: 'TZS',
      earnings: {
        today: 48500,
        thisWeek: 235000,
        thisMonth: 890000,
        completedTripsToday: 11,
        hoursOnlineToday: 6.5,
        fuelWalletBalance: 14500
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function getDemandHeatmap(req, res) {
  try {
    // Dar es Salaam demand hotspots as implemented in Driver App
    const hotspots = [
      {
        name: 'Kariakoo Msimbazi Market',
        lat: -6.8197,
        lng: 39.2743,
        demandLevel: 'high', // high, medium, normal
        activeRequests: 24,
        surgeMultiplier: 1.2
      },
      {
        name: 'Ubungo Bus Terminal / Morogoro Rd',
        lat: -6.7885,
        lng: 39.2081,
        demandLevel: 'high',
        activeRequests: 18,
        surgeMultiplier: 1.15
      },
      {
        name: 'Mwenge Stand & Mlimani City',
        lat: -6.7720,
        lng: 39.2238,
        demandLevel: 'medium',
        activeRequests: 12,
        surgeMultiplier: 1.0
      },
      {
        name: 'Posta Mpya / Kivukoni Ferry',
        lat: -6.8162,
        lng: 39.2905,
        demandLevel: 'high',
        activeRequests: 21,
        surgeMultiplier: 1.25
      }
    ];

    res.json({
      success: true,
      hotspots
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function updateDriverProfile(req, res) {
  try {
    const { drivingLicenseNumber, licenseExpiryDate, latraRegistrationNumber } = req.body;

    res.json({
      success: true,
      message: 'Taarifa za leseni na LATRA zimesasishwa kwa mafanikio.',
      documents: {
        drivingLicenseNumber,
        licenseExpiryDate,
        latraRegistrationNumber,
        status: 'verified'
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}
