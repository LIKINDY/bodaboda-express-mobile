import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../core/widgets/smart_street_map.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../chat/presentation/screens/call_screen.dart';

class ActiveRideTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? rideData;
  const ActiveRideTrackingScreen({super.key, this.rideData});

  @override
  State<ActiveRideTrackingScreen> createState() => _ActiveRideTrackingScreenState();
}

class _ActiveRideTrackingScreenState extends State<ActiveRideTrackingScreen> {
  late Map<String, dynamic> _trip;
  bool _useGoogleMap = false;
  bool _hasTraffic = true;
  int _remainingMinutes = 3;
  double _remainingDistanceKm = 0.85; // 850m
  double _driverMovedDistanceKm = 1.2; // driver already moved 1.2 km
  String _tripStatus = 'Dereva yuko njiani kukufuata';
  Timer? _etaSimulationTimer;

  static const LatLng _driverStartLoc = LatLng(-6.8220, 39.2700);
  static const LatLng _trafficPoint = LatLng(-6.8235, 39.2675);
  static const LatLng _pickupLoc = LatLng(-6.8250, 39.2650);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _trip = widget.rideData ?? {
      'rideId': 'TRIP-DEMO',
      'passenger': UserProfileService.instance.fullName,
      'pickup': 'Kariakoo Msimbazi',
      'dropoff': 'Posta Mpya, Samora Ave',
      'serviceType': 'ride',
      'price': 'TZS 3,000',
      'payment': 'Cash',
      'pin': '4872',
      'driverName': 'Juma Rajab',
      'driverPlate': 'MC 123 ABC • Boxer',
    };

    _updateMapElements();

    // Listen for backend real-time updates
    MockBackendService.instance.onMessageReceived = (msg) {
      if (msg['type'] == 'trip_started' && mounted) {
        setState(() {
          _tripStatus = 'Safari imeanza kuelekea kituo cha mwisho';
          _remainingMinutes = 8;
          _remainingDistanceKm = 4.2;
        });
        _updateMapElements();
      }
    };

    // Simulate ETA progress
    _etaSimulationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && _remainingMinutes > 1) {
        setState(() {
          _remainingMinutes--;
          _remainingDistanceKm = (_remainingDistanceKm - 0.2).clamp(0.1, 10.0);
          _driverMovedDistanceKm += 0.3;
        });
      }
    });
  }

  void _updateMapElements() {
    _markers.clear();
    _polylines.clear();

    // Driver Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverStartLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: _trip['driverName'] ?? 'Dereva: Juma Rajab'),
      ),
    );

    // Pickup Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Kituo Chako: ${_trip['pickup']}'),
      ),
    );

    // Green Polyline: Sehemu isiyo na foleni (Smooth clear road)
    _polylines.add(
      const Polyline(
        polylineId: PolylineId('route_green_clear'),
        points: [_driverStartLoc, _trafficPoint],
        color: Color(0xFF2E7D32), // Vibrant Green = Hakuna Foleni
        width: 6,
      ),
    );

    // Red Polyline: Sehemu yenye foleni (Congestion segment)
    if (_hasTraffic) {
      _polylines.add(
        const Polyline(
          polylineId: PolylineId('route_red_traffic'),
          points: [_trafficPoint, _pickupLoc],
          color: Color(0xFFD32F2F), // Red = Kuna Foleni
          width: 6,
        ),
      );
    } else {
      _polylines.add(
        const Polyline(
          polylineId: PolylineId('route_green_all'),
          points: [_trafficPoint, _pickupLoc],
          color: Color(0xFF2E7D32),
          width: 6,
        ),
      );
    }
  }

  @override
  void dispose() {
    _etaSimulationTimer?.cancel();
    super.dispose();
  }

  void _handleCancelRide() async {
    // If driver has already moved > 0.5 km, record cancellation debt silently/transparently
    if (_driverMovedDistanceKm >= 0.5) {
      await UserProfileService.instance.addCancellationDebt(1500);
      debugPrint('Cancellation penalty recorded: TZS 1,500');
    }
    if (mounted) {
      context.pushNamed('cancel-ride');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pin = _trip['pin'] ?? '4872';
    final isDelivery = _trip['serviceType'] == 'delivery';
    final isForFriend = _trip['isForFriend'] == true || _trip['is_for_friend'] == true;
    final friendName = _trip['friendName'] ?? _trip['friend_name'] ?? 'Rafiki';
    final friendPhone = _trip['friendPhone'] ?? _trip['friend_phone'] ?? '';
    final vehicleType = (_trip['vehicleType'] ?? 'bodaboda').toString().toLowerCase();

    return Scaffold(
      body: Stack(
        children: [
          // ── Map View (Smart Street Map / Google Map toggle) ───────────
          if (!_useGoogleMap)
            SmartStreetMapWidget(
              isLight: !isDark,
              activeTrip: _trip,
              showTraffic: true,
              showShortcuts: true,
              onToggleGoogleMap: () => setState(() => _useGoogleMap = true),
            )
          else
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-6.8235, 39.2675),
                zoom: 15.0,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                if (isDark) {
                  controller.setMapStyle('[{"elementType": "geometry","stylers": [{"color": "#242f3e"}]}]');
                }
              },
            ),

          // ── Top Navigation / Traffic Legend ──────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () => context.goNamed('dashboard'),
                        ),
                      ),
                      // Service & Vehicle Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDelivery ? AppTheme.accentOrange : AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDelivery
                                  ? Icons.inventory_2
                                  : (vehicleType.contains('bajaj')
                                      ? Icons.electric_rickshaw
                                      : (vehicleType.contains('car') ? Icons.directions_car : Icons.motorcycle)),
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isDelivery
                                  ? 'Mzigo (Delivery)'
                                  : (vehicleType.contains('bajaj')
                                      ? 'Bajaji Comfort'
                                      : (vehicleType.contains('car') ? 'Car Taxi' : 'Bodaboda Express')),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Traffic Color Legend & Trip Progress Card ─────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status & ETA
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.access_time_filled, color: AppTheme.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tripStatus,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dakika $_remainingMinutes zilizobaki  •  Masafa: ${(_remainingDistanceKm * 1000).toInt()}m',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // Traffic Indicators: Green = Hakuna foleni, Red = Kuna foleni
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E7D32),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Kijani: Hakuna Foleni',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD32F2F),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Nyekundu: Kuna Foleni',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Driver & Trip Card ─────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isForFriend) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people_alt, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Safari ya Rafiki: $friendName ${friendPhone.isNotEmpty ? "($friendPhone)" : ""} • SMS ya safari na PIN imetumwa kwake moja kwa moja.',
                                style: TextStyle(fontSize: 11, color: Colors.green.shade900, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Security PIN Banner (Prominently displayed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pin, color: AppTheme.primaryBlue, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mpe Dereva OTP hii akifika:',
                                  style: TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                                Text(
                                  'OTP: $pin (Ili a-pin na kuanzisha safari)',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pin,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Driver info row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                          child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _trip['driverName'] ?? 'Juma Rajab',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _trip['driverPlate'] ?? 'MC 123 ABC • Boxer',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        // Rating & fare badge
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 14),
                                  SizedBox(width: 4),
                                  Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _trip['price'] ?? 'TZS 3,000',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ecoGreen, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chat and Call Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                            },
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: const Text('Chat'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CallScreen()));
                            },
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('Piga Simu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.ecoGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Complete Ride / Cancel Ride
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _handleCancelRide,
                            icon: const Icon(Icons.close, color: AppTheme.accentRed, size: 16),
                            label: const Text(
                              'Ghairi Safari',
                              style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.pushNamed('payment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Kamilisha Malipo'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
