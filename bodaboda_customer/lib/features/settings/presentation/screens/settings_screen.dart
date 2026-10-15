import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/localization/app_copy.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appCopy(context, 'Settings', 'Mipangilio')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSetting(context),
          _buildSettingsItem(context, appCopy(context, 'My Profile', 'Wasifu Wangu'), 'profile', icon: Icons.person_outline),
          _buildSettingsItem(context, appCopy(context, 'Change Language', 'Badili lugha'), 'change-language', icon: Icons.language),
          _buildSettingsItem(context, appCopy(context, 'Change Password', 'Badili nenosiri'), 'change-password', icon: Icons.lock_outline),
          _buildSettingsItem(context, appCopy(context, 'Privacy Policy', 'Sera ya faragha'), 'privacy-policy', icon: Icons.privacy_tip_outlined),
          _buildSettingsItem(context, appCopy(context, 'Contact Us', 'Wasiliana nasi'), 'contact-us', icon: Icons.contact_support_outlined),
          _buildSettingsItem(context, appCopy(context, 'About Us', 'Kuhusu sisi'), 'about-us', icon: Icons.info_outline),
          _buildSettingsItem(context, appCopy(context, 'Help and Support', 'Msaada'), 'help-support', icon: Icons.help_outline),
          _buildSettingsItem(context, appCopy(context, 'Delete Account', 'Futa akaunti'), 'delete-account', icon: Icons.delete_outline, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: SwitchListTile.adaptive(
          secondary: Icon(AppSettings.instance.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          title: Text(appCopy(context, 'Dark mode', 'Hali ya giza'), style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(appCopy(context, 'Apply across the whole app', 'Tumia mwonekano huu kwenye app nzima')),
          value: AppSettings.instance.isDarkMode,
          onChanged: AppSettings.instance.setDarkMode,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, String title, String route, {IconData? icon, Color? color}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? AppTheme.darkDivider : Colors.grey.shade200),
      ),
      child: ListTile(
        leading: icon != null ? Icon(icon, color: color ?? AppTheme.primaryBlue) : null,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => context.pushNamed(route),
      ),
    );
  }
}
