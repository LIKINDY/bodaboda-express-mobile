import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../chat/presentation/screens/call_screen.dart';

enum RideMatchState { searching, driverFound }

class RideMatchScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingData;
  const RideMatchScreen({super.key, this.bookingData});

  @override
  State<RideMatchScreen> createState() => _RideMatchScreenState();
}

class _RideMatchScreenState extends State<RideMatchScreen> with TickerProviderStateMixin {
  RideMatchState _state = RideMatchState.searching;
  bool _isCancelled = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _matchTimer;
  Timer? _autoTransitionTimer;
  late String _securePin;
  late Map<String, dynamic> _currentTrip;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _securePin = widget.bookingData?['pin'] ?? (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    _currentTrip = Map<String, dynamic>.from(widget.bookingData ?? {
      'rideId': 'TRIP-DEMO-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'passenger': 'Amina Salum',
      'passengerPhone': '+255 754 892 110',
      'pickup': 'Kariakoo Msimbazi',
      'dropoff': 'Posta Mpya, Samora Ave',
      'price': 'TZS 3,000',
      'payment': 'Cash',
      'serviceType': 'ride',
      'distance': '800m away',
      'tripDistance': '4.8 km',
      'pin': _securePin,
    });
    _currentTrip['pin'] = _securePin;

    // Connect & broadcast ride request to drivers
    MockBackendService.instance.connect();
    MockBackendService.instance.sendRideRequest(_currentTrip);

    MockBackendService.instance.onMessageReceived = (msg) {
      if (msg['type'] == 'ride_accepted' && mounted) {
        _matchTimer?.cancel();
        setState(() {
          _state = RideMatchState.driverFound;
          if (msg['driverName'] != null) _currentTrip['driverName'] = msg['driverName'];
          if (msg['driverPlate'] != null) _currentTrip['driverPlate'] = msg['driverPlate'];
        });
        _scheduleAutoTransitionToTracking();
      }
    };

    // Fallback simulation timer (match driver after 6 seconds if no real driver accepted yet)
    _matchTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && _state == RideMatchState.searching) {
        setState(() => _state = RideMatchState.driverFound);
        _scheduleAutoTransitionToTracking();
      }
    });
  }

  void _scheduleAutoTransitionToTracking() {
    // Automatically transition to live tracking map after 2.5 seconds
    _autoTransitionTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _state == RideMatchState.driverFound && !_isCancelled) {
        _navigateToTracking();
      }
    });
  }

  void _navigateToTracking() {
    _autoTransitionTimer?.cancel();
    context.pushReplacementNamed('ride-tracking', extra: _currentTrip);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _matchTimer?.cancel();
    _autoTransitionTimer?.cancel();
    super.dispose();
  }

  Future<void> _cancelRide() async {
    _matchTimer?.cancel();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ghairi safari?'),
        content: const Text('Ombi hili la majaribio litaghairiwa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Endelea')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ghairi safari')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _isCancelled = true);
      context.goNamed('dashboard');
    } else if (mounted && _state == RideMatchState.searching && !_isCancelled) {
      _matchTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _state = RideMatchState.driverFound);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _state == RideMatchState.searching ? 'Inatafuta Dereva...' : 'Dereva Amekubaliana!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _state == RideMatchState.searching
            ? _SearchingView(
                pulseAnimation: _pulseAnimation,
                onCancel: _cancelRide,
                tripData: _currentTrip,
              )
            : _DriverFoundView(
                pin: _securePin,
                tripData: _currentTrip,
                onTrackRide: _navigateToTracking,
                onCancel: _cancelRide,
                onChat: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen())),
                onCall: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CallScreen())),
              ),
      ),
    );
  }
}

// ─── Searching View ───────────────────────────────────────────────────────────

class _SearchingView extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final VoidCallback onCancel;
  final Map<String, dynamic> tripData;

  const _SearchingView({
    required this.pulseAnimation,
    required this.onCancel,
    required this.tripData,
  });

  @override
  Widget build(BuildContext context) {
    final vType = (tripData['vehicleType'] ?? 'bodaboda').toString().toLowerCase();
    final isForFriend = tripData['isForFriend'] == true || tripData['is_for_friend'] == true;
    final friendName = tripData['friendName'] ?? tripData['friend_name'] ?? 'Rafiki';

    IconData vehicleIcon = Icons.motorcycle;
    String vehicleName = 'Bodaboda';
    if (vType.contains('bajaj')) {
      vehicleIcon = Icons.electric_rickshaw;
      vehicleName = 'Bajaji';
    } else if (vType.contains('car') || vType.contains('taxi')) {
      vehicleIcon = Icons.directions_car;
      vehicleName = 'Car Taxi';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing animation with dynamic vehicle icon
            ScaleTransition(
              scale: pulseAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(vehicleIcon, color: Colors.white, size: 38),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Inatafuta Dereva wa $vehicleName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              isForFriend
                  ? 'Unamwombea usafiri rafiki yako: $friendName.\nTafadhali subiri wakati tunamtafutia dereva wa karibu...'
                  : 'Tafadhali subiri wakati tunamtafutia\nudereva anayekaribu nawe...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            if (isForFriend) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sms_outlined, size: 16, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SMS ya safari itatumwa kwa $friendName mara dereva akipatikana.',
                        style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFE0E0E0),
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 48),
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined, color: AppTheme.accentRed),
              label: const Text('Ghairi Ombi', style: TextStyle(color: AppTheme.accentRed)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Driver Found View ────────────────────────────────────────────────────────

class _DriverFoundView extends StatelessWidget {
  final String pin;
  final Map<String, dynamic> tripData;
  final VoidCallback onTrackRide;
  final VoidCallback onCancel;
  final VoidCallback onChat;
  final VoidCallback onCall;

  const _DriverFoundView({
    required this.pin,
    required this.tripData,
    required this.onTrackRide,
    required this.onCancel,
    required this.onChat,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final isForFriend = tripData['isForFriend'] == true || tripData['is_for_friend'] == true;
    final friendName = tripData['friendName'] ?? tripData['friend_name'] ?? 'Rafiki';
    final friendPhone = tripData['friendPhone'] ?? tripData['friend_phone'] ?? '';
    final vType = (tripData['vehicleType'] ?? 'bodaboda').toString().toLowerCase();

    String vehicleBadge = 'BODABODA';
    if (vType.contains('bajaj')) vehicleBadge = 'BAJAJI';
    if (vType.contains('car') || vType.contains('taxi')) vehicleBadge = 'CAR TAXI';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isForFriend) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_alt, color: Colors.green, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safari kwa ajili ya: $friendName',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                        ),
                        if (friendPhone.isNotEmpty)
                          Text('Simu: $friendPhone', style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
                        const Text(
                          'Taarifa na PIN zimetumwa kwa SMS kwa rafiki yako.',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Driver card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, size: 36, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Sergio Ramasis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              vehicleBadge,
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Plate: TZ-001-A • $vehicleBadge', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('4.9', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                          const SizedBox(width: 4),
                          Text('(142 safari)', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _CircleAction(icon: Icons.phone, color: AppTheme.ecoGreen, onTap: onCall),
                    const SizedBox(height: 8),
                    _CircleAction(icon: Icons.chat_bubble_outline, color: AppTheme.primaryBlue, onTap: onChat),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ETA Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wakati wa kufika', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const Text('Dakika 3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Hali ya Safari', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const Text('Inakuja', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ecoGreen)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Secure PIN Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_outline, size: 18, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text(
                    'Namba yako ya Usalama (PIN)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Mpe dereva namba hii ili athibitishe safari yako. Usimwambie mtu mwingine!',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue.withValues(alpha: 0.9), AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'PIN ya Usalama',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pin.split('').map((digit) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 52,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Text(
                              digit,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'Salama · Siri · Inaisha baada ya safari',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onTrackRide,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Fuatilia Safari', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined, color: AppTheme.accentRed),
              label: const Text('Ghairi Safari', style: TextStyle(color: AppTheme.accentRed, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Circle Action Button ─────────────────────────────────────────────────────

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
