import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/user_profile_service.dart';

class CustomerSignUpScreen extends StatefulWidget {
  const CustomerSignUpScreen({super.key});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  int _selectedAvatarIndex = 0;
  final List<String> _avatarPresets = [
    'assets/images/avatar_1.png',
    'assets/images/avatar_2.png',
    'assets/images/avatar_3.png',
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _pickPhoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chagua Picha ya Wasifu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  title: const Text('Piga Picha Sasa (Camera)'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedAvatarIndex = 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Picha imechaguliwa!')),
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.ecoGreen,
                    child: Icon(Icons.photo_library, color: Colors.white),
                  ),
                  title: const Text('Chagua Kutoka Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedAvatarIndex = 2);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Picha imechaguliwa kutoka gallery!')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tafadhali ingiza namba sahihi ya simu (angalau tarakimu 9)'),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final fullPhone = phone.startsWith('0') 
        ? '+255${phone.substring(1)}' 
        : (phone.startsWith('+255') ? phone : '+255$phone');

    await UserProfileService.instance.saveProfile(
      fullName: name,
      phone: fullPhone,
      photoPath: 'avatar_$_selectedAvatarIndex',
    );

    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to OTP screen for phone verification
      context.pushNamed('otp', extra: fullPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Title
                Text(
                  'Fungua Akaunti ya Mteja',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Jaza taarifa zako ili uweze kuomba usafiri wa bodaboda na kusafirisha mizigo.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 28),

                // Profile Picture Picker
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryBlue, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey.shade100,
                          child: Icon(
                            _selectedAvatarIndex == 0 ? Icons.person : Icons.face,
                            size: 54,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.add_a_photo, size: 16, color: AppTheme.primaryBlue),
                    label: const Text(
                      'Weka Picha ya Wasifu',
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Full Name Field
                const Text(
                  'Jina Kamili',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Mfano: Juma Ali Hassan',
                    prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryBlue),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Tafadhali ingiza jina lako kamili';
                    }
                    if (val.trim().split(' ').length < 2) {
                      return 'Tafadhali andika majina mawili kamili';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number Field
                const Text(
                  'Namba ya Simu',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇹🇿 +255', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 24, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                    hintText: '712 345 678',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Tafadhali ingiza namba ya simu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Inactivity security badge notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ulinzi wa Akaunti: Mfumo unakuhakikishia usalama. Ukikaa wiki 1 (siku 7) bila kuomba usafiri, mfumo utakuomba kuhakiki namba yako tena kwa OTP.',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Jisajili & Pokea OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Link to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Tayari una akaunti? ', style: TextStyle(color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () => context.pushNamed('login'),
                      child: const Text(
                        'Ingia Hapa',
                        style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
