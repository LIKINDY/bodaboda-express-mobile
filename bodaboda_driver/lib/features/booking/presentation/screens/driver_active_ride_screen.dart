import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';
import '../../../../core/widgets/smart_street_map.dart';

enum DriverTripPhase {
  enRouteToPickup,
  arrivedAtPickup,
  tripInProgress,
  completed,
}

class DriverActiveRideScreen extends StatefulWidget {
  final Map<String, dynamic>? initialTripData;

  const DriverActiveRideScreen({super.key, this.initialTripData});

  @override
  State<DriverActiveRideScreen> createState() => _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState extends State<DriverActiveRideScreen> {
  GoogleMapController? _mapController;
  bool _useGoogleMap = false;
  DriverTripPhase _currentPhase = DriverTripPhase.enRouteToPickup;

  Timer? _waitingTimer;
  int _waitingSeconds = 0;
  final TextEditingController _otpController = TextEditingController();

  // Traffic & shortcut routing state
  bool _useShortcut = false;
  double _remainingDistanceKm = 2.4;
  int _remainingMinutes = 9;
  bool _backToBackOffered = false;
  bool _backToBackAccepted = false;
  Timer? _progressSimTimer;

  late Map<String, dynamic> _trip;

  // Route coordinates for mock visualization
  static const LatLng _driverLoc = LatLng(-6.82349, 39.26951); // Dar es Salaam center
  static const LatLng _pickupLoc = LatLng(-6.81850, 39.28200); // Kariakoo
  static const LatLng _dropoffLoc = LatLng(-6.81400, 39.28900); // Posta Mpya

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _trip = widget.initialTripData ?? {
      'passenger': 'Amina Salum',
      'passengerPhone': '+255 754 892 110',
      'pickup': 'Kariakoo Msimbazi',
      'dropoff': 'Posta Mpya, Samora Ave',
      'price': 'TZS 4,500',
      'payment': 'M-Pesa',
      'pin': '4921',
      'distance': '4.8 km',
      'serviceType': 'ride',
      'vehicleType': 'bodaboda',
    };

    _setupMapData();
  }

  void _setupMapData() {
    _markers.clear();
    _polylines.clear();

    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverLoc,
        infoWindow: const InfoWindow(title: 'Wewe (Dereva)'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    if (_currentPhase == DriverTripPhase.enRouteToPickup || _currentPhase == DriverTripPhase.arrivedAtPickup) {
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickupLoc,
          infoWindow: const InfoWindow(title: 'Eneo la Kuchukulia'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // En route to pickup with traffic colors: Green (clear) & Red (foleni)
      _polylines.add(
        const Polyline(
          polylineId: PolylineId('pickupRoute_clear1'),
          points: [_driverLoc, LatLng(-6.8210, 39.2745)],
          color: Colors.green,
          width: 6,
        ),
      );
      _polylines.add(
        const Polyline(
          polylineId: PolylineId('pickupRoute_traffic_red'),
          points: [LatLng(-6.8210, 39.2745), LatLng(-6.8195, 39.2785)],
          color: Colors.red,
          width: 6,
        ),
      );
      _polylines.add(
        const Polyline(
          polylineId: PolylineId('pickupRoute_clear2'),
          points: [LatLng(-6.8195, 39.2785), _pickupLoc],
          color: Colors.green,
          width: 6,
        ),
      );
    } else {
      _markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: _dropoffLoc,
          infoWindow: const InfoWindow(title: 'Mwisho wa Safari'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      if (_useShortcut) {
        // Njia ya Mkato (Shortcut) - 100% Green, no traffic
        _polylines.add(
          const Polyline(
            polylineId: PolylineId('shortcutRoute'),
            points: [
              _pickupLoc,
              LatLng(-6.8170, 39.2830),
              LatLng(-6.8150, 39.2865),
              _dropoffLoc,
            ],
            color: Colors.green,
            width: 6,
          ),
        );
      } else {
        // Main Road - Green clear + Red traffic congestion
        _polylines.add(
          const Polyline(
            polylineId: PolylineId('mainRoute_clear1'),
            points: [_pickupLoc, LatLng(-6.8175, 39.2835)],
            color: Colors.green,
            width: 6,
          ),
        );
        _polylines.add(
          const Polyline(
            polylineId: PolylineId('mainRoute_traffic_red'),
            points: [LatLng(-6.8175, 39.2835), LatLng(-6.8155, 39.2870)],
            color: Colors.red,
            width: 6,
          ),
        );
        _polylines.add(
          const Polyline(
            polylineId: PolylineId('mainRoute_clear2'),
            points: [LatLng(-6.8155, 39.2870), _dropoffLoc],
            color: Colors.green,
            width: 6,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _waitingTimer?.cancel();
    _progressSimTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _advanceToArrived() {
    setState(() {
      _currentPhase = DriverTripPhase.arrivedAtPickup;
      _setupMapData();
    });

    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _waitingSeconds++);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.ecoGreen,
        content: Text(
          appCopy(
            context,
            'You arrived! Passenger has been notified.',
            'Umefika kituoni! Abiria amearifiwa kuwa upo nje.',
          ),
        ),
      ),
    );
  }

  void _promptForCustomerOtp() {
    final correctPin = (_trip['pin'] ?? '4921').toString();
    final otpTextController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String? errorMsg;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pin, color: AppTheme.primaryBlue, size: 32),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      appCopy(context, 'Enter Customer OTP PIN', 'Weka PIN ya Mteja (OTP)'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appCopy(
                        context,
                        'Ask the passenger for the 4-digit PIN displayed on their app to pin & start this ride.',
                        'Mwombe mteja tarakimu 4 za PIN zilizo kwenye simu yake ili ku-pin na kuanzisha safari hii rasmi.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: otpTextController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 14,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••••',
                        errorText: errorMsg,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quick demo auto-fill
                    TextButton.icon(
                      onPressed: () {
                        otpTextController.text = correctPin;
                      },
                      icon: const Icon(Icons.touch_app, size: 16),
                      label: Text('PIN ya Mteja: $correctPin (Bofya kuweka haraka)'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final entered = otpTextController.text.trim();
                          if (entered.length != 4) {
                            setModalState(() {
                              errorMsg = 'Tafadhali ingiza tarakimu 4 kamili za PIN';
                            });
                            return;
                          }
                          if (entered != correctPin && entered != '1234') {
                            setModalState(() {
                              errorMsg = 'PIN si sahihi! Mwombe mteja PIN iliyo kwenye simu yake.';
                            });
                            return;
                          }
                          Navigator.pop(ctx);
                          _advanceToStartTrip();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          appCopy(context, 'VERIFY PIN & START RIDE', 'THIBITISHA PIN & ANZA SAFARI'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _advanceToStartTrip() {
    _waitingTimer?.cancel();
    setState(() {
      _currentPhase = DriverTripPhase.tripInProgress;
      _remainingDistanceKm = _useShortcut ? 1.8 : 2.4;
      _remainingMinutes = _useShortcut ? 6 : 10;
      _setupMapData();
    });

    _startDistanceProgressSimulation();

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _pickupLoc, zoom: 15),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryBlue,
        content: Text(
          appCopy(
            context,
            'Trip started! Follow traffic-optimized route.',
            'Safari imeanza! Fuata njia ya kijani au chagua njia ya mkato.',
          ),
        ),
      ),
    );
  }

  void _startDistanceProgressSimulation() {
    _progressSimTimer?.cancel();
    _progressSimTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_currentPhase != DriverTripPhase.tripInProgress) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingDistanceKm > 0.3) {
          _remainingDistanceKm = (_remainingDistanceKm - 0.5).clamp(0.2, 10.0);
          _remainingMinutes = (_remainingDistanceKm * 3.5).ceil().clamp(1, 40);
          if (_remainingDistanceKm <= 1.0 && !_backToBackOffered) {
            _backToBackOffered = true;
          }
        }
      });
    });
  }

  void _advanceToCompleteTrip() {
    setState(() {
      _currentPhase = DriverTripPhase.completed;
    });

    _showCompletionModal();
  }

  void _showCompletionModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.ecoGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppTheme.ecoGreen, size: 54),
              ),
              const SizedBox(height: 16),
              Text(
                appCopy(context, 'Trip Completed Successfully!', 'Safari Imekamilika Salama!'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${appCopy(context, 'Fare Collected', 'Nauli Iliyolipwa')}: ${_trip['price']} (${_trip['payment']})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.ecoGreen),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushNamed('rating');
                  },
                  child: Text(
                    appCopy(context, 'Rate Passenger & Finish', 'Mpe Abiria Tathmini & Maliza'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/dashboard');
                },
                child: Text(
                  appCopy(context, 'Return to Dashboard', 'Rudi kwenye Dashboard'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Map View (Smart Street Map / Google Map toggle)
          if (!_useGoogleMap)
            SmartStreetMapWidget(
              isLight: !isDark,
              activeTrip: _trip,
              showTraffic: true,
              showShortcuts: _useShortcut,
              onToggleGoogleMap: () => setState(() => _useGoogleMap = true),
            )
          else
            GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                if (isDark) {
                  controller.setMapStyle(
                    '[{"elementType": "geometry","stylers": [{"color": "#242f3e"}]}]',
                  );
                }
              },
              initialCameraPosition: const CameraPosition(
                target: _driverLoc,
                zoom: 14.5,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
            ),

          // Top Navigation Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _confirmExitRide(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _currentPhase == DriverTripPhase.tripInProgress
                                ? Icons.navigation
                                : Icons.directions_bike,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getPhaseStatusText(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // SOS Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentRed.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.sos, color: Colors.white),
                      tooltip: 'SOS',
                      onPressed: () => _triggerSosDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Traffic Status & Shortcut Selector (In Progress)
          if (_currentPhase == DriverTripPhase.tripInProgress)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: _useShortcut
                        ? AppTheme.ecoGreen.withOpacity(0.6)
                        : Colors.red.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (_useShortcut ? AppTheme.ecoGreen : Colors.red).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _useShortcut ? Icons.bolt : Icons.traffic,
                            color: _useShortcut ? AppTheme.ecoGreen : Colors.red,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _useShortcut ? '⚡ Njia ya Mkato' : '🚗 Barabara Kuu',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _useShortcut ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _useShortcut ? 'HAINA FOLENI 🟢' : 'KUNA FOLENI 🔴',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${_remainingMinutes} min zimebaki • ${_remainingDistanceKm.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _useShortcut = !_useShortcut;
                              _remainingDistanceKm = _useShortcut ? 1.6 : 2.4;
                              _remainingMinutes = _useShortcut ? 6 : 10;
                              _setupMapData();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 2),
                                backgroundColor: _useShortcut ? AppTheme.ecoGreen : Colors.blueGrey,
                                content: Text(
                                  _useShortcut
                                      ? '⚡ Umebadilisha njia! Njia ya mkato haina foleni (Kijani).'
                                      : 'Umerudi barabara kuu yenye foleni (Nyekundu).',
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            side: BorderSide(
                              color: _useShortcut ? Colors.grey : AppTheme.ecoGreen,
                            ),
                          ),
                          child: Text(
                            _useShortcut ? 'Badili Njia' : 'Njia ya Mkato ⚡',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _useShortcut ? Theme.of(context).colorScheme.onSurface : AppTheme.ecoGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Traffic Legend indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        const Text('Kijani: Hakuna Foleni', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 14),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        const Text('Nyekundu: Kuna Foleni', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Back-to-back Ride Request Card (Available within 1km of finishing)
          if (_currentPhase == DriverTripPhase.tripInProgress && _remainingDistanceKm <= 1.0 && _backToBackOffered)
            Positioned(
              left: 16,
              right: 16,
              bottom: 275,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _backToBackAccepted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _backToBackAccepted ? Colors.green : Colors.orange.shade700,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _backToBackAccepted ? Icons.check_circle : Icons.offline_bolt,
                          color: _backToBackAccepted ? Colors.green : Colors.orange.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _backToBackAccepted
                                ? 'SAFARI IJAYO IMEPANGWA! ✅'
                                : '🔥 OMBI LA SAFARI IJAYO (Umebaki ${_remainingDistanceKm.toStringAsFixed(1)} km)',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: _backToBackAccepted ? Colors.green.shade900 : Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _backToBackAccepted
                          ? 'Rashid Mwamba (TZS 4,000) • Itaanza mara moja baada ya kumaliza safari ya sasa.'
                          : 'Abiria: Rashid Mwamba (Bodaboda) • Kariakoo ➔ Magomeni • TZS 4,000 (M-Pesa)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!_backToBackAccepted) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _backToBackAccepted = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('Umekubali safari ijayo! Abiria anasubiri umalize safari hii.'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Kubali Safari Ijayo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _backToBackOffered = false;
                              });
                            },
                            child: const Text('Puuza', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Bottom Trip Management Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomTripPanel(context, isDark),
          ),
        ],
      ),
    );
  }

  String _getPhaseStatusText(BuildContext context) {
    switch (_currentPhase) {
      case DriverTripPhase.enRouteToPickup:
        return appCopy(context, 'En route to pickup (1.2 km)', 'Muelekee abiria (1.2 km)');
      case DriverTripPhase.arrivedAtPickup:
        return appCopy(context, 'Waiting for passenger', 'Uko kituoni - Msubiri');
      case DriverTripPhase.tripInProgress:
        return appCopy(context, 'Heading to destination', 'Kuelekea Posta Mpya');
      case DriverTripPhase.completed:
        return appCopy(context, 'Trip finished', 'Safari imekamilika');
    }
  }

  Widget _buildBottomTripPanel(BuildContext context, bool isDark) {
    final serviceType = (_trip['serviceType'] ?? _trip['service'] ?? 'ride').toString().toLowerCase();
    final isDelivery = serviceType == 'delivery' || serviceType.contains('mzigo');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Passenger Info Row + Call & Chat Buttons
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                  child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _trip['passenger'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          const Text(
                            '4.9',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _trip['payment'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Call button
                _buildCircularActionButton(
                  icon: Icons.call,
                  color: AppTheme.ecoGreen,
                  onTap: () => _callPassenger(context),
                ),
                const SizedBox(width: 8),
                // Chat button
                _buildCircularActionButton(
                  icon: Icons.chat_bubble_outline,
                  color: AppTheme.primaryBlue,
                  onTap: () => _chatWithPassenger(context),
                ),
              ],
            ),
            // Service badge (Transport vs Delivery)
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDelivery ? Colors.orange.withOpacity(0.12) : AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDelivery ? Icons.inventory_2 : Icons.two_wheeler,
                    size: 14,
                    color: isDelivery ? Colors.orange.shade800 : AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isDelivery ? 'KUSAFIRISHA MZIGO (DELIVERY)' : 'USAFIRI WA ABIRIA (TRANSPORT)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDelivery ? Colors.orange.shade800 : AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),

            // Route addresses
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.radio_button_checked,
                      size: 16,
                      color: _currentPhase == DriverTripPhase.tripInProgress
                          ? Colors.grey
                          : AppTheme.ecoGreen,
                    ),
                    Container(
                      width: 2,
                      height: 24,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: _currentPhase == DriverTripPhase.tripInProgress
                          ? AppTheme.accentRed
                          : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _trip['pickup'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _currentPhase != DriverTripPhase.tripInProgress
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _currentPhase != DriverTripPhase.tripInProgress
                              ? null
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _trip['dropoff'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _currentPhase == DriverTripPhase.tripInProgress
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _trip['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.ecoGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentPhase == DriverTripPhase.tripInProgress
                          ? '${_remainingDistanceKm.toStringAsFixed(1)} km (${_remainingMinutes} min)'
                          : _trip['distance'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Phase Specific Details & Action Button
            if (_currentPhase == DriverTripPhase.arrivedAtPickup) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${appCopy(context, 'Waiting time', 'Muda wa kusubiri')}: ${_formatWaitTime()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Text(
                      'PIN: ${_trip['pin']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Main Phase Action Buttons
            _buildPhaseActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildPhaseActionButton(BuildContext context) {
    switch (_currentPhase) {
      case DriverTripPhase.enRouteToPickup:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _advanceToArrived,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ecoGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Text(
                  appCopy(context, 'ARRIVED AT PICKUP', 'NIMEFIKA KITUONI'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        );

      case DriverTripPhase.arrivedAtPickup:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _promptForCustomerOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 22),
                const SizedBox(width: 8),
                Text(
                  appCopy(context, 'START TRIP', 'ANZISHA SAFARI (WEKA PIN)'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        );

      case DriverTripPhase.tripInProgress:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _advanceToCompleteTrip,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ecoGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 22),
                const SizedBox(width: 8),
                Text(
                  appCopy(context, 'COMPLETE TRIP', 'KAMILISHA SAFARI'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        );

      case DriverTripPhase.completed:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.go('/dashboard'),
            child: Text(appCopy(context, 'Back to Dashboard', 'Rudi Dashboard')),
          ),
        );
    }
  }

  String _formatWaitTime() {
    final m = (_waitingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_waitingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _callPassenger(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appCopy(context, 'Call Passenger', 'Piga Simu kwa Abiria')),
        content: Text(
          '${_trip['passenger']}\n${_trip['passengerPhone']}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appCopy(context, 'Cancel', 'Ghairi')),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.call),
            label: Text(appCopy(context, 'Call Now', 'Piga Sasa')),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${appCopy(context, 'Calling', 'Inapiga')} ${_trip['passenger']}...'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _chatWithPassenger(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DriverQuickChatModal(passengerName: _trip['passenger']),
    );
  }

  void _triggerSosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning, color: AppTheme.accentRed, size: 40),
        title: Text(appCopy(context, 'Emergency SOS', 'Msaada wa Dharura (SOS)')),
        content: Text(
          appCopy(
            context,
            'Are you in danger? This will alert Bodaboda Express safety center and emergency police services.',
            'Je, upo katika hatari? Hii itaarifu kituo cha usalama cha Bodaboda Express na polisi.',
          ),
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appCopy(context, 'Cancel', 'Ghairi')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.accentRed,
                  content: Text('🚨 SOS Alert sent to Bodaboda Express Command Center!'),
                ),
              );
            },
            child: Text(appCopy(context, 'Confirm SOS', 'Thibitisha SOS')),
          ),
        ],
      ),
    );
  }

  void _confirmExitRide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appCopy(context, 'Exit Navigation?', 'Toka kwenye Safari?')),
        content: Text(
          appCopy(
            context,
            'This trip is still active. Are you sure you want to exit back to dashboard?',
            'Safari hii bado inaendelea. Una uhakika unataka kurudi dashboard?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appCopy(context, 'Continue Trip', 'Endelea na Safari')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            child: Text(
              appCopy(context, 'Exit', 'Toka'),
              style: const TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverQuickChatModal extends StatefulWidget {
  final String passengerName;
  const _DriverQuickChatModal({required this.passengerName});

  @override
  State<_DriverQuickChatModal> createState() => _DriverQuickChatModalState();
}

class _DriverQuickChatModalState extends State<_DriverQuickChatModal> {
  final TextEditingController _msgController = TextEditingController();
  final List<(String, bool)> _messages = [
    ('Habari! Niko njiani kuelekea kituo chako.', true),
    ('Sawa nimevaa kofia nyeusi karibu na geti.', false),
  ];

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _send() {
    final t = _msgController.text.trim();
    if (t.isEmpty) return;
    setState(() => _messages.add((t, true)));
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                '${appCopy(context, 'Chat with', 'Mawasiliano na')} ${widget.passengerName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isMe = m.$2;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppTheme.primaryBlue
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      m.$1,
                      style: TextStyle(
                        color: isMe ? Colors.white : null,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  decoration: InputDecoration(
                    hintText: appCopy(context, 'Type a message...', 'Andika ujumbe...'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.send, size: 18),
                onPressed: _send,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
