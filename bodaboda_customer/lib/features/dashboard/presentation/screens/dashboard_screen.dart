import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../core/widgets/smart_street_map.dart';

// ─── State for booking flow ───────────────────────────────────────────────────

enum BookingStep { addressInput, vehicleSelect, availableRides }
enum VehicleType { bodaboda, bajaji, car }
enum ServiceType { ride, delivery }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BookingStep _step = BookingStep.addressInput;
  ServiceType _selectedService = ServiceType.ride;
  VehicleType _selectedVehicle = VehicleType.bodaboda;
  String _selectedPaymentMethod = 'Cash';
  bool _showRideButtons = false;
  bool _useLightMap = false;

  // Book for a Friend state
  bool _isForFriend = false;
  final _friendNameController = TextEditingController();
  final _friendPhoneController = TextEditingController();

  final _pickupController = TextEditingController(text: 'Current location');
  final _dropoffController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _friendNameController.dispose();
    _friendPhoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Connect to mock backend when dashboard opens
    MockBackendService.instance.connect();
    
    // Check weekly inactivity requirement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWeeklyInactivity();
    });
  }

  void _checkWeeklyInactivity() {
    if (UserProfileService.instance.isReverificationRequired()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.security, color: AppTheme.accentRed),
              SizedBox(width: 8),
              Text('Uhakiki wa Usalama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'Umekaa zaidi ya wiki moja (siku 7) pasipo kutumia app kuomba usafiri au huduma. Kulingana na sera ya usalama, unalazimika kuhakiki namba yako tena kwa OTP ili kuendelea.',
          ),
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed('otp', extra: UserProfileService.instance.phone);
              },
              icon: const Icon(Icons.verified_user),
              label: const Text('Hakiki Namba Sasa (OTP)'),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            ),
          ],
        ),
      );
    }
  }

  void _startRideBooking(ServiceType service, VehicleType vehicle, String fare, String payment) {
    if (UserProfileService.instance.isReverificationRequired()) {
      _checkWeeklyInactivity();
      return;
    }

    if (_isForFriend) {
      final friendName = _friendNameController.text.trim();
      final friendPhone = _friendPhoneController.text.trim();
      if (friendName.isEmpty || friendPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tafadhali jaza jina na namba ya simu ya rafiki yako'),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }
    }

    final String vTypeStr = vehicle == VehicleType.bodaboda ? 'bodaboda' : (vehicle == VehicleType.bajaji ? 'bajaji' : 'car');
    final String vLabelStr = vehicle == VehicleType.bodaboda
        ? 'Bodaboda Express'
        : (vehicle == VehicleType.bajaji ? 'Bajaji Comfort' : 'Car Taxi (Cab)');
    final String distStr = vehicle == VehicleType.bodaboda
        ? '800m away'
        : (vehicle == VehicleType.bajaji ? '1.2 km away' : '2.0 km away');

    final booking = {
      'rideId': 'TRIP-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'is_for_friend': _isForFriend,
      'isForFriend': _isForFriend,
      'friend_name': _isForFriend ? _friendNameController.text.trim() : null,
      'friendName': _isForFriend ? _friendNameController.text.trim() : null,
      'friend_phone': _isForFriend ? _friendPhoneController.text.trim() : null,
      'friendPhone': _isForFriend ? _friendPhoneController.text.trim() : null,
      'recipient_name': _isForFriend ? _friendNameController.text.trim() : null,
      'recipient_phone': _isForFriend ? _friendPhoneController.text.trim() : null,
      'passenger': _isForFriend ? _friendNameController.text.trim() : UserProfileService.instance.fullName,
      'passengerPhone': _isForFriend ? _friendPhoneController.text.trim() : UserProfileService.instance.phone,
      'bookedBy': UserProfileService.instance.fullName,
      'bookedByPhone': UserProfileService.instance.phone,
      'pickup': _pickupController.text.trim().isEmpty ? 'Kariakoo Msimbazi' : _pickupController.text.trim(),
      'dropoff': _dropoffController.text.trim().isEmpty ? 'Posta Mpya, Samora Ave' : _dropoffController.text.trim(),
      'serviceType': service == ServiceType.ride ? 'ride' : 'delivery',
      'serviceLabel': service == ServiceType.ride ? 'Usafiri wa Abiria' : 'Kusafirisha Mzigo (Delivery)',
      'vehicleType': vTypeStr,
      'vehicleLabel': vLabelStr,
      'price': fare,
      'payment': payment,
      'pin': (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString(),
      'distance': distStr,
      'tripDistance': '4.8 km',
    };

    MockBackendService.instance.sendRideRequest(booking);
    context.pushNamed('ride-match', extra: booking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          // ── Simulated Map Background ──────────────────────────────────────
          _MapBackground(isLight: _useLightMap),

          // ── Top menu & zoom buttons ───────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MapIconButton(icon: Icons.menu, onTap: () => _scaffoldKey.currentState?.openDrawer()),
                  Row(
                    children: [
                      _MapIconButton(
                        icon: Icons.notifications_none,
                        onTap: () => context.pushNamed('notifications'),
                      ),
                      const SizedBox(width: 8),
                      _MapIconButton(icon: Icons.search, onTap: _searchDestination),
                      const SizedBox(width: 8),
                      _MapIconButton(
                        icon: Icons.layers_outlined,
                        onTap: () => setState(() => _useLightMap = !_useLightMap),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Sheet: Step-by-step ────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _step == BookingStep.addressInput
                  ? _AddressInputSheet(
                      key: const ValueKey('address'),
                      pickupController: _pickupController,
                      dropoffController: _dropoffController,
                      onConfirm: () {
                        if (_dropoffController.text.trim().isNotEmpty) {
                          setState(() => _step = BookingStep.vehicleSelect);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Ingiza mahali unapokwenda'),
                              backgroundColor: AppTheme.accentRed,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        }
                      },
                      onRecentPlaceChanged: () => setState(() {}),
                    )
                  : _step == BookingStep.vehicleSelect
                      ? _VehicleSelectSheet(
                          key: const ValueKey('vehicle'),
                          selected: _selectedVehicle,
                          onSelect: (v) => setState(() => _selectedVehicle = v),
                          onBack: () => setState(() => _step = BookingStep.addressInput),
                          onNext: () => setState(() {
                            _step = BookingStep.availableRides;
                            _showRideButtons = false;
                          }),
                        )
                      : _AvailableRidesSheet(
                          key: const ValueKey('rides'),
                          selectedService: _selectedService,
                          selectedVehicle: _selectedVehicle,
                          selectedPayment: _selectedPaymentMethod,
                          isForFriend: _isForFriend,
                          friendNameController: _friendNameController,
                          friendPhoneController: _friendPhoneController,
                          onToggleForFriend: (val) => setState(() => _isForFriend = val),
                          onServiceChanged: (s) => setState(() => _selectedService = s),
                          onVehicleChanged: (v) => setState(() => _selectedVehicle = v),
                          onPaymentChanged: (p) => setState(() => _selectedPaymentMethod = p),
                          onBack: () => setState(() => _step = BookingStep.vehicleSelect),
                          onRideNow: (service, vehicle, fare, payment) {
                            _startRideBooking(service, vehicle, fare, payment);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchDestination() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _dropoffController.text);
        return AlertDialog(
          title: Text(appCopy(context, 'Search destination', 'Tafuta unakoenda')),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: appCopy(context, 'e.g. Kariakoo, Dar es Salaam', 'Mfano: Kariakoo, Dar es Salaam'),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(appCopy(context, 'Cancel', 'Ghairi'))),
            FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(appCopy(context, 'Search', 'Tafuta'))),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _dropoffController.text = result;
        _step = BookingStep.addressInput;
      });
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              color: AppTheme.primaryBlue,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: const Icon(Icons.person, color: Colors.white, size: 34),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UserProfileService.instance.fullName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          UserProfileService.instance.phone,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(Icons.account_balance_wallet_outlined, 'My Wallet', () {
                    Navigator.pop(context);
                    context.pushNamed('wallet');
                  }),
                  _buildDrawerItem(Icons.history, 'Ride History', () {
                    Navigator.pop(context);
                    context.pushNamed('history');
                  }),
                  _buildDrawerItem(Icons.settings_outlined, 'Settings', () {
                    Navigator.pop(context);
                    context.pushNamed('settings');
                  }),
                  const Divider(height: 24, indent: 24, endIndent: 24),
                  _buildDrawerItem(Icons.logout, 'Logout', () {
                    Navigator.pop(context);
                    context.go('/login');
                  }, color: AppTheme.accentRed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

// ─── Real Google Map Widget ───────────────────────────────────────────────────

class _MapBackground extends StatefulWidget {
  final bool isLight;
  const _MapBackground({this.isLight = false});

  @override
  State<_MapBackground> createState() => _MapBackgroundState();
}

class _MapBackgroundState extends State<_MapBackground> {
  GoogleMapController? mapController;
  bool _useGoogleMap = false;

  final LatLng _center = const LatLng(-6.82349, 39.26951); // Dar es Salaam

  // ── Mock Markers for nearby drivers ──
  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('driver_1'),
      position: const LatLng(-6.820, 39.270),
      infoWindow: const InfoWindow(title: 'Bodaboda (Juma)'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ),
    Marker(
      markerId: const MarkerId('driver_2'),
      position: const LatLng(-6.825, 39.265),
      infoWindow: const InfoWindow(title: 'Bodaboda (Ali)'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ),
    Marker(
      markerId: const MarkerId('driver_3'),
      position: const LatLng(-6.821, 39.268),
      infoWindow: const InfoWindow(title: 'Bodaboda (Rashid)'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ),
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (!_useGoogleMap) {
      return SmartStreetMapWidget(
        isLight: widget.isLight,
        onToggleGoogleMap: () => setState(() => _useGoogleMap = true),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 14.5,
          ),
          markers: _markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        Positioned(
          top: 60,
          right: 14,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onPressed: () => setState(() => _useGoogleMap = false),
            icon: const Icon(Icons.layers, size: 16),
            label: const Text('Ramani ya Mfumo', style: TextStyle(fontSize: 11)),
          ),
        ),
      ],
    );
  }
}

// ─── Map Icon Button ──────────────────────────────────────────────────────────

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6)],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}

// ─── Address Input Bottom Sheet ───────────────────────────────────────────────

class _AddressInputSheet extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final VoidCallback onConfirm;
  final VoidCallback onRecentPlaceChanged;

  const _AddressInputSheet({
    super.key,
    required this.pickupController,
    required this.dropoffController,
    required this.onConfirm,
    required this.onRecentPlaceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appCopy(context, 'Choose locations', 'Chagua anwani'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Pickup row
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryBlue, width: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pickupController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: appCopy(context, 'Pickup location', 'Mahali ulipo sasa'),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                Divider(height: 1, color: Colors.grey.shade200, indent: 24),

                // Dropoff row
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: dropoffController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: appCopy(context, 'Where to?', 'Unapoenda...'),
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                    if (dropoffController.text.isNotEmpty)
                      Icon(Icons.close, size: 16, color: Colors.grey.shade400),
                  ],
                ),

                const SizedBox(height: 12),

                // Recent places
                Text(appCopy(context, 'Recent places', 'Maeneo ya hivi karibuni'), style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
                const SizedBox(height: 8),
                ...[
                  ('Office', '2972 Weshwewe Rd Sana Ava, Pasia', Icons.business_outlined),
                  ('Home', '2972 Beeringo Co Santa, Paria', Icons.home_outlined),
                  ('Home', '2003 Westamar Rd Santa, Do Santa', Icons.home_outlined),
                  ('Home', 'Home', Icons.home_outlined),
                ].map((item) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Icon(item.$3, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(item.$2, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      onTap: () {
                        dropoffController.text = item.$1;
                        onRecentPlaceChanged();
                      },
                    )),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(appCopy(context, 'Confirm location', 'Thibitisha mahali'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vehicle Selection Sheet ──────────────────────────────────────────────────

class _VehicleSelectSheet extends StatelessWidget {
  final VehicleType selected;
  final ValueChanged<VehicleType> onSelect;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _VehicleSelectSheet({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                Text(appCopy(context, 'Choose a ride', 'Chagua usafiri'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(appCopy(context, 'Select vehicle type', 'Chagua aina ya usafiri'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _VehicleCard(
                    label: 'Bodaboda',
                    icon: Icons.motorcycle,
                    isSelected: selected == VehicleType.bodaboda,
                    onTap: () => onSelect(VehicleType.bodaboda),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _VehicleCard(
                    label: 'Bajaji',
                    icon: Icons.electric_rickshaw,
                    isSelected: selected == VehicleType.bajaji,
                    onTap: () => onSelect(VehicleType.bajaji),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _VehicleCard(
                    label: 'Car Taxi',
                    icon: Icons.directions_car,
                    badge: 'TAXI',
                    isSelected: selected == VehicleType.car,
                    onTap: () => onSelect(VehicleType.car),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(appCopy(context, 'Find a driver', 'Tafuta dereva'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.06) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            Icon(icon, size: 40, color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryBlue : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Available Rides Sheet ────────────────────────────────────────────────────

class _AvailableRidesSheet extends StatelessWidget {
  final ServiceType selectedService;
  final VehicleType selectedVehicle;
  final String selectedPayment;
  final bool isForFriend;
  final TextEditingController friendNameController;
  final TextEditingController friendPhoneController;
  final ValueChanged<bool> onToggleForFriend;
  final ValueChanged<ServiceType> onServiceChanged;
  final ValueChanged<VehicleType> onVehicleChanged;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onBack;
  final void Function(ServiceType service, VehicleType vehicle, String fare, String payment) onRideNow;

  const _AvailableRidesSheet({
    super.key,
    required this.selectedService,
    required this.selectedVehicle,
    required this.selectedPayment,
    required this.isForFriend,
    required this.friendNameController,
    required this.friendPhoneController,
    required this.onToggleForFriend,
    required this.onServiceChanged,
    required this.onVehicleChanged,
    required this.onPaymentChanged,
    required this.onBack,
    required this.onRideNow,
  });

  String get _currentFare {
    if (selectedVehicle == VehicleType.bodaboda) {
      return selectedService == ServiceType.ride ? 'TZS 3,000' : 'TZS 2,500';
    } else if (selectedVehicle == VehicleType.bajaji) {
      return selectedService == ServiceType.ride ? 'TZS 5,000' : 'TZS 4,500';
    } else {
      return selectedService == ServiceType.ride ? 'TZS 9,000' : 'TZS 8,000';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodaFare = selectedService == ServiceType.ride ? 'TZS 3,000' : 'TZS 2,500';
    final bajajiFare = selectedService == ServiceType.ride ? 'TZS 5,000' : 'TZS 4,500';
    final carFare = selectedService == ServiceType.ride ? 'TZS 9,000' : 'TZS 8,000';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, -4))],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top back handle
            Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 18, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appCopy(context, 'Choose Ride or Delivery', 'Chagua Usafiri au Mzigo'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Service Type Selector (Usafiri vs Kusafirisha Mzigo)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onServiceChanged(ServiceType.ride),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedService == ServiceType.ride ? AppTheme.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: selectedService == ServiceType.ride
                              ? [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 6)]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_pin_circle_outlined,
                              size: 18,
                              color: selectedService == ServiceType.ride ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Usafiri (Ride)',
                              style: TextStyle(
                                color: selectedService == ServiceType.ride ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onServiceChanged(ServiceType.delivery),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedService == ServiceType.delivery ? AppTheme.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: selectedService == ServiceType.delivery
                              ? [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 6)]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 18,
                              color: selectedService == ServiceType.delivery ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Mzigo (Delivery)',
                              style: TextStyle(
                                color: selectedService == ServiceType.delivery ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Service Description subtitle
            Text(
              selectedService == ServiceType.ride
                  ? '👤 Kumpeleka mteja mahali fulani salama na haraka.'
                  : '📦 Kusafirisha kifurushi au mzigo kwa umakini hadi mlangoni.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 14),

            // 2. Vehicles with Automatic Exact Calculated Fare
            _VehicleSelectionCard(
              title: 'Bodaboda Express',
              subtitle: 'Mwendo kasi • 800m (Dakika 3)',
              fare: bodaFare,
              icon: Icons.motorcycle,
              isSelected: selectedVehicle == VehicleType.bodaboda,
              onTap: () => onVehicleChanged(VehicleType.bodaboda),
            ),
            const SizedBox(height: 10),
            _VehicleSelectionCard(
              title: 'Bajaji Comfort',
              subtitle: 'Nafasi kubwa na kivuli • 1.2km (Dakika 5)',
              fare: bajajiFare,
              icon: Icons.electric_rickshaw,
              isSelected: selectedVehicle == VehicleType.bajaji,
              onTap: () => onVehicleChanged(VehicleType.bajaji),
            ),
            const SizedBox(height: 10),
            _VehicleSelectionCard(
              title: 'Car Taxi (Cab)',
              subtitle: 'Gari ya kisasa • AC • Watu 4 (2.0km)',
              fare: carFare,
              icon: Icons.directions_car,
              badge: 'TAXI',
              isSelected: selectedVehicle == VehicleType.car,
              onTap: () => onVehicleChanged(VehicleType.car),
            ),
            const SizedBox(height: 16),

            // 3. Passenger Option: Book for Myself vs Book for a Friend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mpanda Safari (Passenger):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                if (isForFriend)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Rafiki Yangu',
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onToggleForFriend(false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isForFriend ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !isForFriend ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 16, color: !isForFriend ? AppTheme.primaryBlue : Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'Mimi Mwenyewe',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !isForFriend ? AppTheme.primaryBlue : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onToggleForFriend(true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isForFriend ? AppTheme.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isForFriend ? [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 4)] : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_alt_outlined, size: 16, color: isForFriend ? Colors.white : Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'Rafiki Yangu',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isForFriend ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isForFriend) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.contact_phone_outlined, size: 16, color: AppTheme.primaryBlue),
                        SizedBox(width: 6),
                        Text('Taarifa za Rafiki Anayepanda:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBlue)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: friendNameController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Jina Kamili la Rafiki (e.g. Baraka Elias)',
                        prefixIcon: const Icon(Icons.person_outline, size: 18),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: friendPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Namba ya Simu (+255 7XX XXX XXX)',
                        prefixIcon: const Icon(Icons.phone_android, size: 18),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '💡 Dereva atampigia simu rafiki yako na SMS ya safari itatumwa kwake moja kwa moja.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // 4. Payment Method Choice
            const Text(
              'Chagua Njia ya Malipo:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _PaymentMethodChip(
                  label: 'Taslimu (Cash)',
                  icon: Icons.money,
                  isSelected: selectedPayment == 'Cash',
                  onTap: () => onPaymentChanged('Cash'),
                ),
                const SizedBox(width: 8),
                _PaymentMethodChip(
                  label: 'Tuma kwa Simu',
                  icon: Icons.phone_android,
                  isSelected: selectedPayment == 'Mobile Money',
                  onTap: () => onPaymentChanged('Mobile Money'),
                ),
                const SizedBox(width: 8),
                _PaymentMethodChip(
                  label: 'Pochi (Wallet)',
                  icon: Icons.account_balance_wallet_outlined,
                  isSelected: selectedPayment == 'Wallet',
                  onTap: () => onPaymentChanged('Wallet'),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 5. Request Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  onRideNow(selectedService, selectedVehicle, _currentFare, selectedPayment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selectedService == ServiceType.ride ? Icons.directions_bike : Icons.local_shipping,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedService == ServiceType.ride ? (isForFriend ? "Agizia Rafiki Usafiri" : "Omba Usafiri") : "Tuma Mzigo"} Sasa · $_currentFare',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fare;
  final IconData icon;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleSelectionCard({
    required this.title,
    required this.subtitle,
    required this.fare,
    required this.icon,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue.withOpacity(0.12) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? AppTheme.primaryBlue : Colors.black87, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fare,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Bei Kamili', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.ecoGreen.withOpacity(0.12) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.ecoGreen : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppTheme.ecoGreen : Colors.black87),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.ecoGreen : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
