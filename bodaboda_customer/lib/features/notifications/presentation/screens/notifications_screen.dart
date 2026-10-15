import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Trip Completed!',
        'message': 'You have safely reached your destination. Please rate your driver.',
        'time': 'Just now',
        'isRead': false,
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
      },
      {
        'title': 'New Promo Available 🎁',
        'message': 'Get 20% off your next 3 rides using promo code BODA20.',
        'time': '2 hours ago',
        'isRead': false,
        'icon': Icons.local_offer_outlined,
        'color': AppTheme.primaryBlue,
      },
      {
        'title': 'Wallet Top-up Successful',
        'message': 'TZS 10,000 has been successfully added to your wallet.',
        'time': 'Yesterday',
        'isRead': true,
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppTheme.primaryBlue,
      },
      {
        'title': 'Welcome to Bodaboda Express!',
        'message': 'We are glad to have you. Enjoy fast and safe rides.',
        'time': 'Oct 01, 2026',
        'isRead': true,
        'icon': Icons.waving_hand_outlined,
        'color': Colors.orange,
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appCopy(context, 'Notifications', 'Taarifa'), style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: appCopy(context, 'Mark all as read', 'Soma zote'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(appCopy(context, 'All marked as read', 'Zote zimesomwa'))),
              );
            },
          )
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isRead = notif['isRead'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isRead ? null : Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (notif['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(notif['icon'], color: notif['color'], size: 24),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif['title'],
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentRed,
                              shape: BoxShape.circle,
                            ),
                          )
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          notif['message'],
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notif['time'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            appCopy(context, 'No new notifications', 'Hakuna taarifa mpya'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            appCopy(context, 'We will let you know when something happens.', 'Tutakujulisha kunapokuwa na jambo.'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
