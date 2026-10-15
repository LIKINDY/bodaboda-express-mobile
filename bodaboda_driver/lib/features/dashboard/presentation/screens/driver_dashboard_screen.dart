import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/screens/address_screen.dart';
import '../../../offers/presentation/screens/special_offers_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../../../core/widgets/smart_street_map.dart';
import '../../../booking/presentation/widgets/incoming_ride_modal.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    _HomeMapPage(
      onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
    ),
    const AddressScreen(),
    const WalletScreen(),
    const SpecialOffersScreen(),
    const ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, appCopy(context, 'Home', 'Nyumbani'), 0),
              _buildNavItem(Icons.favorite_outline, Icons.favorite, appCopy(context, 'Favourite', 'Vipendwa'), 1),
              _buildNavItemCenter(2),
              _buildNavItem(Icons.local_offer_outlined, Icons.local_offer, appCopy(context, 'Offers', 'Ofa'), 3),
              _buildNavItem(Icons.person_outline, Icons.person, appCopy(context, 'Profile', 'Wasifu'), 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlinedIcon, IconData filledIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? AppTheme.primaryBlue : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryBlue : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemCenter(int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryBlue : AppTheme.primaryBlue.withOpacity(0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            'Wallet',
            style: TextStyle(
              color: isSelected ? AppTheme.primaryBlue : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Profile header
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Juma Ali',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '+255 712 *** 70',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
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
                  _buildDrawerItem(Icons.person_outline, 'Profile', () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 4);
                  }),
                  _buildDrawerItem(Icons.location_on_outlined, 'Address', () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 1);
                  }),
                  _buildDrawerItem(Icons.local_gas_station, 'Fuel Wallet', () {
                    Navigator.pop(context);
                    context.push('/fuel-wallet');
                  }),
                  _buildDrawerItem(Icons.insert_chart_outlined, appCopy(context, 'Earnings & Reports', 'Mapato na Takwimu'), () {
                    Navigator.pop(context);
                    context.pushNamed('earnings');
                  }),
                  _buildDrawerItem(Icons.history, appCopy(context, 'Ride History', 'Historia ya Safari'), () {
                    Navigator.pop(context);
                    context.pushNamed('history');
                  }),
                  _buildDrawerItem(Icons.report_problem_outlined, 'Complain', () => Navigator.pop(context)),
                  _buildDrawerItem(Icons.people_outline, 'Referral', () {
                    Navigator.pop(context);
                    context.pushNamed('referral');
                  }),
                  _buildDrawerItem(Icons.info_outline, 'About Us', () {
                    Navigator.pop(context);
                    context.pushNamed('about-us');
                  }),
                  _buildDrawerItem(Icons.settings_outlined, 'Settings', () {
                    Navigator.pop(context);
                    context.pushNamed('settings');
                  }),
                  _buildDrawerItem(Icons.help_outline, 'Help', () {
                    Navigator.pop(context);
                    context.pushNamed('help-support');
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

// ─── Home Map Page ───────────────────────────────────────────────────────────

class _HomeMapPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;

  const _HomeMapPage({required this.onOpenDrawer});

  @override
  State<_HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<_HomeMapPage> {
  bool _isOnline = true;
  bool _showHeatmap = true;
  bool _showDashboardBalance = false;
  bool _useGoogleMap = false;
  String _mockTripState = 'none'; // none, request, accepted, started
  
  Map<String, dynamic>? _currentRequestData;
  GoogleMapController? _mapController;

  // ── Heatmap & High Passenger Demand Hotspots ──
  final Set<Marker> _demandMarkers = {
    Marker(
      markerId: const MarkerId('hotspot_kariakoo'),
      position: const LatLng(-6.8210, 39.2740),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      infoWindow: const InfoWindow(
        title: '🔥 Kariakoo Msimbazi',
        snippet: 'Abiria 18 wanasubiri (Mahitaji ya Juu)',
      ),
    ),
    Marker(
      markerId: const MarkerId('hotspot_posta'),
      position: const LatLng(-6.8145, 39.2885),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: const InfoWindow(
        title: '🔥 Posta Mpya / Samora',
        snippet: 'Abiria 12 wanasubiri usafiri',
      ),
    ),
    Marker(
      markerId: const MarkerId('hotspot_ubungo'),
      position: const LatLng(-6.7865, 39.2130),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      infoWindow: const InfoWindow(
        title: '🔥 Ubungo Bus Terminal',
        snippet: 'Abiria 24 wanasubiri (Mahitaji Makubwa)',
      ),
    ),
    Marker(
      markerId: const MarkerId('hotspot_mwenge'),
      position: const LatLng(-6.7710, 39.2395),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: const InfoWindow(
        title: '🔥 Mwenge Stand',
        snippet: 'Abiria 15 wanasubiri usafiri',
      ),
    ),
  };

  final Set<Circle> _demandCircles = {
    Circle(
      circleId: const CircleId('circle_kariakoo'),
      center: const LatLng(-6.8210, 39.2740),
      radius: 550,
      fillColor: Colors.red.withOpacity(0.18),
      strokeColor: Colors.red.withOpacity(0.5),
      strokeWidth: 2,
    ),
    Circle(
      circleId: const CircleId('circle_posta'),
      center: const LatLng(-6.8145, 39.2885),
      radius: 450,
      fillColor: Colors.orange.withOpacity(0.18),
      strokeColor: Colors.orange.withOpacity(0.5),
      strokeWidth: 2,
    ),
    Circle(
      circleId: const CircleId('circle_ubungo'),
      center: const LatLng(-6.7865, 39.2130),
      radius: 650,
      fillColor: Colors.red.withOpacity(0.20),
      strokeColor: Colors.red.withOpacity(0.6),
      strokeWidth: 2,
    ),
    Circle(
      circleId: const CircleId('circle_mwenge'),
      center: const LatLng(-6.7710, 39.2395),
      radius: 500,
      fillColor: Colors.orange.withOpacity(0.18),
      strokeColor: Colors.orange.withOpacity(0.5),
      strokeWidth: 2,
    ),
  };

  @override
  void initState() {
    super.initState();
    MockBackendService.instance.connect();
    MockBackendService.instance.onRideRequestReceived = (data) {
      if (mounted) {
        if (!_isOnline) {
          // OFFLINE: Ignore request
          return;
        }
        setState(() {
          _currentRequestData = data;
          _mockTripState = 'request';
        });
        _showIncomingRideModal(data);
      }
    };
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
    MockBackendService.instance.updateDriverStatus(_isOnline ? 'online' : 'offline');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isOnline ? AppTheme.ecoGreen : Colors.grey.shade800,
        content: Text(
          _isOnline
              ? appCopy(context, 'You are ONLINE. Receiving rides & deliveries!', 'Sasa uko ONLINE. Uko tayari kupokea maombi ya usafiri na mizigo!')
              : appCopy(context, 'You are OFFLINE. No requests will be received.', 'Sasa uko OFFLINE. Hupokei maombi hadi utakapowasha mtandao tena.'),
        ),
      ),
    );
  }

  void _showIncomingRideModal(Map<String, dynamic> data) {
    IncomingRideModal.show(
      context,
      rideData: data,
      onAccept: () {
        MockBackendService.instance.acceptRide(data['rideId'] ?? 'TRIP-DEMO');
        setState(() {
          _mockTripState = 'accepted';
        });
        context.pushNamed('driver-active-ride', extra: data);
      },
      onDecline: () {
        setState(() {
          _mockTripState = 'none';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appCopy(context, 'Ride request declined', 'Ombi la safari limekataliwa')),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Only disconnect if the app is fully closed, usually kept alive.
    super.dispose();
  }

  Future<void> _openDriverSearch() async {
    final controller = TextEditingController();
    final destination = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appCopy(context, 'Search an area', 'Tafuta eneo')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: appCopy(context, 'Enter a place name', 'Andika jina la eneo')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(appCopy(context, 'Cancel', 'Ghairi'))),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(appCopy(context, 'Search', 'Tafuta'))),
        ],
      ),
    );
    controller.dispose();
    if (destination != null && destination.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${appCopy(context, 'Showing demo area', 'Eneo la mfano')}: $destination')),
      );
    }
  }

  void _showDemoLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appCopy(context, 'Demo location centered on Dar es Salaam', 'Eneo la mfano limewekwa katikati ya Dar es Salaam'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Map Background (Smart Street Map / Google Map toggle)
          if (!_useGoogleMap)
            SmartStreetMapWidget(
              isLight: !isDark,
              showHotspots: _showHeatmap,
              showTraffic: true,
              showShortcuts: true,
              onToggleGoogleMap: () => setState(() => _useGoogleMap = true),
            )
          else
            GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                if (isDark) {
                  controller.setMapStyle('[{"elementType": "geometry","stylers": [{"color": "#242f3e"}]}]');
                }
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(-6.82349, 39.26951), // Dar es Salaam
                zoom: 14.5,
              ),
              markers: _showHeatmap ? _demandMarkers : {},
              circles: _showHeatmap ? _demandCircles : {},
              polylines: _mockTripState == 'started' || _mockTripState == 'accepted' 
                  ? {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: const [
                          LatLng(-6.82349, 39.26951),
                          LatLng(-6.822, 39.271),
                        ],
                        color: AppTheme.primaryBlue,
                        width: 5,
                      )
                    }
                  : {},
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),

          // Top bar with hamburger & icons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: widget.onOpenDrawer,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.menu, color: AppTheme.textDark, size: 22),
                      ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.pushNamed('earnings'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insights, color: AppTheme.ecoGreen, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            '48.5k',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MapControl(
                    icon: _showHeatmap ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                    onTap: () {
                      setState(() => _showHeatmap = !_showHeatmap);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          backgroundColor: _showHeatmap ? Colors.deepOrange : Colors.grey.shade800,
                          content: Text(
                            _showHeatmap
                                ? appCopy(context, '🔥 Heatmap ON: High demand passenger zones visible', '🔥 Ramani ya Mahitaji IMEWASHWA: Inaonyesha maeneo yenye abiria wengi')
                                : appCopy(context, 'Heatmap OFF', 'Ramani ya Mahitaji IMEZIMWA'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _MapControl(
                    icon: Icons.notifications_none, 
                    onTap: () => context.pushNamed('notifications')
                  ),
                  const SizedBox(width: 8),
                  _MapControl(icon: Icons.search, onTap: _openDriverSearch),
                  const SizedBox(width: 8),
                  _MapControl(icon: Icons.location_on_outlined, onTap: _showDemoLocation),
                ],
              ),
            ),
          ),

          // Decorative overlay
          if (_mockTripState == 'request')
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.3))),

          // Bottom panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Fuel Card Mini Widget ──────────────────────────
                  StatefulBuilder(
                    builder: (context, setCardState) {
                      // We need to manage the eye toggle state
                      return GestureDetector(
                        onTap: () => context.push('/fuel-wallet'),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF4CAF50), Color(0xFFD32F2F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1A2340), Color(0xFF243B6E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Fuel Card',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('Express', style: TextStyle(color: Colors.white, fontSize: 9)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Balance', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              _showDashboardBalance ? 'TZS 45,000' : '****',
                                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                setCardState(() {
                                                  _showDashboardBalance = !_showDashboardBalance;
                                                });
                                              },
                                              child: Icon(
                                                _showDashboardBalance ? Icons.visibility : Icons.visibility_off,
                                                color: Colors.white54,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Online / Offline Switcher (Hupokei request ukiwa offline)
                  Container(
                    decoration: BoxDecoration(
                      color: _isOnline
                          ? AppTheme.ecoGreen.withOpacity(0.12)
                          : Colors.grey.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isOnline
                            ? AppTheme.ecoGreen.withOpacity(0.6)
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _isOnline ? AppTheme.ecoGreen : Colors.grey.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              if (_isOnline)
                                BoxShadow(
                                  color: AppTheme.ecoGreen.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: Icon(
                            _isOnline ? Icons.power_settings_new : Icons.power_off,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _isOnline ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isOnline
                                        ? appCopy(context, 'ONLINE (READY)', 'UKO ONLINE (TAYARI)')
                                        : appCopy(context, 'OFFLINE (PAUSED)', 'UKO OFFLINE (PUMZIKA)'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: _isOnline ? AppTheme.ecoGreen : Colors.grey.shade700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _isOnline
                                    ? appCopy(context, 'Receiving rides & deliveries', 'Unapokea maombi ya usafiri na mizigo')
                                    : appCopy(context, 'Requests paused. Tap to go online', 'Hupokei maombi. Bofya uanze kazi'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isOnline,
                          activeColor: AppTheme.ecoGreen,
                          onChanged: (val) => _toggleOnlineStatus(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search bar
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _openDriverSearch,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.textLight, size: 20),
                        const SizedBox(width: 12),
                           Text(appCopy(context, 'Where would you go?', 'Ungependa kwenda wapi?'),
                             style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMockTripCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockTripCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sampleTrip = {
      'rideId': 'TRIP-DEMO-99',
      'passenger': 'Amina Salum',
      'passengerPhone': '+255 754 892 110',
      'pickup': 'Kariakoo Msimbazi',
      'dropoff': 'Posta Mpya, Samora Ave',
      'price': 'TZS 4,500',
      'payment': 'M-Pesa',
      'distance': '1.2 km away',
      'tripDistance': '4.8 km',
      'pin': '4921',
      'serviceType': 'ride',
      'vehicleType': 'bodaboda',
    };

    final activeData = _currentRequestData ?? sampleTrip;
    final serviceType = (activeData['serviceType'] ?? activeData['service'] ?? 'ride').toString().toLowerCase();
    final isDelivery = serviceType == 'delivery' || serviceType.contains('mzigo');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.radar, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appCopy(context, 'Driver Ride Center', 'Kituo cha Safari za Dereva'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      appCopy(context, 'Real-time booking dispatch', 'Mfumo wa safari za moja kwa moja'),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (_isOnline ? AppTheme.ecoGreen : Colors.grey).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: _isOnline ? Colors.green : Colors.grey, size: 8),
                    const SizedBox(width: 4),
                    Text(
                      _isOnline ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _isOnline ? AppTheme.ecoGreen : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Service Type Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDelivery ? Colors.orange.withOpacity(0.12) : AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDelivery ? Colors.orange.withOpacity(0.4) : AppTheme.primaryBlue.withOpacity(0.3),
              ),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (!_isOnline) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(appCopy(context, 'You are OFFLINE. Switch to ONLINE to receive requests.', 'Uko OFFLINE. Washa ONLINE ili kupokea maombi.')),
                        ),
                      );
                      return;
                    }
                    _showIncomingRideModal(activeData);
                  },
                  icon: const Icon(Icons.notifications_active, size: 16),
                  label: Text(
                    appCopy(context, '15s Ride Alert', 'Ombi la Safari (15s)'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      'driver-active-ride',
                      extra: activeData,
                    );
                  },
                  icon: const Icon(Icons.navigation, size: 16),
                  label: Text(
                    appCopy(context, 'Active Ride', 'Safari ya Sasa'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapControl({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppTheme.textDark, size: 22),
          ),
        ),
      );
}
