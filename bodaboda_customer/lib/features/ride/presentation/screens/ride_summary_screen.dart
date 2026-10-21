import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../core/services/mock_backend_service.dart';
import 'request_success_screen.dart';
import '../../../payment/presentation/screens/select_payment_screen.dart';

class RideSummaryScreen extends StatefulWidget {
  const RideSummaryScreen({super.key});

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  String _paymentMethod = 'Cash';
  String _vehicleType = 'bodaboda'; // 'bodaboda', 'bajaji', 'car'
  bool _isForFriend = false;
  final TextEditingController _friendNameController = TextEditingController();
  final TextEditingController _friendPhoneController = TextEditingController();

  @override
  void dispose() {
    _friendNameController.dispose();
    _friendPhoneController.dispose();
    super.dispose();
  }

  Future<void> _changePaymentMethod() async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SelectPaymentScreen()),
    );
    if (selected != null && mounted) setState(() => _paymentMethod = selected);
  }

  int get _baseFareAmount {
    if (_vehicleType == 'bajaji') return 6000;
    if (_vehicleType == 'car') return 10000;
    return 4000;
  }

  int get _vatAmount => (_baseFareAmount * 0.18).round();
  int get _promoDiscount => 500;
  int get _totalAmount => _baseFareAmount + _vatAmount - _promoDiscount;

  void _confirmAndRequest() {
    if (_isForFriend) {
      final name = _friendNameController.text.trim();
      final phone = _friendPhoneController.text.trim();
      if (name.isEmpty || phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tafadhali jaza jina na namba ya simu ya rafiki yako'),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final bookingPayload = {
      'rideId': 'TRIP-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'pickup': 'Mlimani City Mall',
      'dropoff': 'Posta Mpya',
      'vehicleType': _vehicleType,
      'is_for_friend': _isForFriend,
      'isForFriend': _isForFriend,
      'friend_name': _isForFriend ? _friendNameController.text.trim() : null,
      'friendName': _isForFriend ? _friendNameController.text.trim() : null,
      'friend_phone': _isForFriend ? _friendPhoneController.text.trim() : null,
      'friendPhone': _isForFriend ? _friendPhoneController.text.trim() : null,
      'passenger': _isForFriend ? _friendNameController.text.trim() : UserProfileService.instance.fullName,
      'passengerPhone': _isForFriend ? _friendPhoneController.text.trim() : UserProfileService.instance.phone,
      'price': 'TSH ${_totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
      'payment': _paymentMethod,
      'pin': (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString(),
    };

    MockBackendService.instance.sendRideRequest(bookingPayload);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RequestSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muhtasari wa Safari (Ride Summary)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pick-up & Drop-off
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, color: AppTheme.primaryBlue, size: 16),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Eneo la Kuchukulia (Pick-up)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Mlimani City Mall', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 24,
                          width: 2,
                          child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.accentRed, size: 16),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Eneo la Kushukia (Drop-off)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Posta Mpya, Samora Ave', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Category Selector
            const Text('Aina ya Chombo (Vehicle Category)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildVehicleOption('bodaboda', 'Bodaboda', Icons.motorcycle, '15 min'),
                const SizedBox(width: 8),
                _buildVehicleOption('bajaji', 'Bajaji', Icons.electric_rickshaw, '20 min'),
                const SizedBox(width: 8),
                _buildVehicleOption('car', 'Car Taxi', Icons.directions_car, '18 min', badge: 'TAXI'),
              ],
            ),
            const SizedBox(height: 16),

            // Book for a Friend Option
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isForFriend ? Icons.people_alt : Icons.person,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Mpanda Safari:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        ChoiceChip(
                          label: Text(_isForFriend ? 'Kwa Rafiki' : 'Mimi Mwenyewe'),
                          selected: _isForFriend,
                          selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                          onSelected: (val) => setState(() => _isForFriend = val),
                        ),
                      ],
                    ),
                    if (_isForFriend) ...[
                      const Divider(height: 20),
                      TextField(
                        controller: _friendNameController,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Jina Kamili la Rafiki',
                          hintText: 'Mfano: Baraka Elias',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _friendPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Namba ya Simu ya Rafiki',
                          hintText: '+255 7XX XXX XXX',
                          prefixIcon: Icon(Icons.phone_android, size: 20),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '💡 Dereva atampigia simu rafiki yako na SMS itatumwa kwake moja kwa moja.',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fare Breakdown
            const Text('Mchanganuo wa Nauli (Fare Breakdown)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFareRow('Nauli ya Msingi (${_vehicleType.toUpperCase()})', 'TSH ${_baseFareAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
                    const SizedBox(height: 8),
                    _buildFareRow('VAT (18%)', 'TSH ${_vatAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
                    const SizedBox(height: 8),
                    _buildFareRow('Punguzo la Promo', '-TSH $_promoDiscount', isPromo: true),
                    const Divider(height: 24),
                    _buildFareRow('Jumla Kuu (Total)', 'TSH ${_totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method
            const Text('Njia ya Malipo (Payment Method)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const Icon(Icons.money, color: AppTheme.ecoGreen, size: 30),
                title: Text(_paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Lipa baada ya safari kukamilika'),
                trailing: TextButton(
                  onPressed: _changePaymentMethod,
                  child: const Text('Badilisha'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            ElevatedButton(
              onPressed: _confirmAndRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isForFriend ? 'Thibitisha Safari ya Rafiki' : 'Thibitisha Safari Yako',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleOption(String type, String label, IconData icon, String eta, {String? badge}) {
    final isSelected = _vehicleType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _vehicleType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              Icon(icon, color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade700, size: 30),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(eta, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFareRow(String title, String amount, {bool isPromo = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: isTotal || isPromo ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isPromo ? AppTheme.ecoGreen : Colors.black87,
          ),
        ),
      ],
    );
  }
}

