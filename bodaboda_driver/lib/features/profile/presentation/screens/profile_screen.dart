import 'package:flutter/material.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fullNameController = TextEditingController(text: 'Juma Ali');
  final _phoneController = TextEditingController(text: '+255 712 345 678');
  final _emailController = TextEditingController(text: 'juma@example.com');
  final _streetController = TextEditingController(text: 'Kariakoo Street');
  final _licenseNumberController = TextEditingController(text: 'DL-8849201-TZ');
  final _latraNumberController = TextEditingController(text: 'LATRA-2026-MC-4921');
  bool _isLicenseUploaded = true;
  bool _isLatraUploaded = true;
  String? _selectedCity = 'Dar es Salaam';
  String? _selectedDistrict = 'Ilala';
  
  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _licenseNumberController.dispose();
    _latraNumberController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appCopy(context, 'Profile updated successfully!', 'Wasifu umesasishwa kikamilifu!')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appCopy(context, 'Edit Profile', 'Hariri Wasifu'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Profile Header (Avatar) ───
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 50, color: AppTheme.primaryBlue),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppTheme.darkCard : Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _fullNameController.text,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appCopy(context, 'Professional Driver', 'Dereva Mtaalamu'),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ─── Profile Details Form ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appCopy(context, 'Personal Information', 'Taarifa Binafsi'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    context,
                    label: appCopy(context, 'Full Name', 'Jina Kamili'),
                    controller: _fullNameController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    label: appCopy(context, 'Phone Number', 'Namba ya Simu'),
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    label: appCopy(context, 'Email Address', 'Barua Pepe'),
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    appCopy(context, 'Location Details', 'Taarifa za Makazi'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    context,
                    label: appCopy(context, 'Street', 'Mtaa'),
                    controller: _streetController,
                    icon: Icons.home_work_outlined,
                  ),
                  const SizedBox(height: 16),
                  
                  // City Dropdown
                  _buildDropdownField(
                    context,
                    label: appCopy(context, 'City', 'Mji'),
                    icon: Icons.location_city_outlined,
                    value: _selectedCity,
                    items: ['Dar es Salaam', 'Mwanza', 'Arusha', 'Dodoma'],
                    onChanged: (v) => setState(() => _selectedCity = v),
                  ),
                  const SizedBox(height: 16),

                  // District Dropdown
                  _buildDropdownField(
                    context,
                    label: appCopy(context, 'District', 'Wilaya'),
                    icon: Icons.map_outlined,
                    value: _selectedDistrict,
                    items: ['Ilala', 'Kinondoni', 'Temeke', 'Ubungo'],
                    onChanged: (v) => setState(() => _selectedDistrict = v),
                  ),
                  const SizedBox(height: 28),

                  // ─── Mandatory Driver Documents Section ───
                  Row(
                    children: [
                      const Icon(Icons.verified, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        appCopy(context, 'Driver Verification Documents', 'Nyaraka za Udereva (Leseni & LATRA)'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appCopy(
                      context,
                      'Mandatory: Please fill your driving license and LATRA certification to keep your driver account active.',
                      'Lazima: Jaza namba za Leseni na LATRA hapa ndani ya wasifu ili akaunti yako iwe hai na uanze kupokea safari.',
                    ),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    context,
                    label: appCopy(context, 'Driving License Number', 'Namba ya Leseni ya Udereva'),
                    controller: _licenseNumberController,
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _isLicenseUploaded = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Picha ya Leseni imehifadhiwa!'), backgroundColor: AppTheme.ecoGreen),
                        );
                      },
                      icon: Icon(_isLicenseUploaded ? Icons.check_circle : Icons.upload_file, color: _isLicenseUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue, size: 18),
                      label: Text(
                        _isLicenseUploaded ? 'Picha ya Leseni: Imepakiwa Kikamilifu ✓' : 'Pakia Picha ya Leseni',
                        style: TextStyle(color: _isLicenseUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    context,
                    label: appCopy(context, 'LATRA Certification / Permit Number', 'Namba ya Stika / Cheti cha LATRA'),
                    controller: _latraNumberController,
                    icon: Icons.confirmation_number_outlined,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _isLatraUploaded = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Stika ya LATRA imehifadhiwa!'), backgroundColor: AppTheme.ecoGreen),
                        );
                      },
                      icon: Icon(_isLatraUploaded ? Icons.check_circle : Icons.upload_file, color: _isLatraUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue, size: 18),
                      label: Text(
                        _isLatraUploaded ? 'Stika ya LATRA: Imepakiwa Kikamilifu ✓' : 'Pakia Picha ya LATRA',
                        style: TextStyle(color: _isLatraUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── Action Buttons ───
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(appCopy(context, 'Cancel', 'Ghairi'), style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  appCopy(context, 'Save', 'Hifadhi'),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Theme.of(context).colorScheme.outlineVariant : Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Theme.of(context).colorScheme.outlineVariant : Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
