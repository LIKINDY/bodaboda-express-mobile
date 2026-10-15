import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  // Mock data for history
  final List<Map<String, dynamic>> _rides = [
    {
      'id': '1',
      'date': 'Oct 05, 2026 - 14:30',
      'driver': 'Juma Ali',
      'pickup': 'Mlimani City',
      'dropoff': 'Posta',
      'price': 'TZS 4,500',
      'status': 'Completed',
    },
    {
      'id': '2',
      'date': 'Oct 04, 2026 - 09:15',
      'driver': 'Salum J',
      'pickup': 'Kariakoo',
      'dropoff': 'Makumbusho',
      'price': 'TZS 3,000',
      'status': 'Completed',
    },
    {
      'id': '3',
      'date': 'Oct 01, 2026 - 18:45',
      'driver': 'Unknown',
      'pickup': 'Ubungo',
      'dropoff': 'Kimara',
      'price': 'TZS 5,000',
      'status': 'Cancelled',
    },
  ];

  void _deleteRide(int index) {
    setState(() {
      _rides.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appCopy(context, 'Ride history deleted.', 'Historia ya safari imefutwa.')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appCopy(context, 'Delete Record?', 'Futa Kumbukumbu?')),
        content: Text(appCopy(context, 'Are you sure you want to delete this ride from your history?', 'Una uhakika unataka kufuta safari hii kwenye historia yako?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appCopy(context, 'Cancel', 'Ghairi')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteRide(index);
            },
            child: Text(appCopy(context, 'Delete', 'Futa')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appCopy(context, 'Ride History', 'Historia ya Safari')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _rides.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    appCopy(context, 'No ride history yet.', 'Hauna historia ya safari bado.'),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rides.length,
              itemBuilder: (context, index) {
                final ride = _rides[index];
                final isCompleted = ride['status'] == 'Completed';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ride['date'],
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ride['status'],
                                style: TextStyle(
                                  color: isCompleted ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.circle, size: 12, color: AppTheme.primaryBlue),
                                Container(width: 2, height: 20, color: Colors.grey.shade300),
                                const Icon(Icons.location_on, size: 16, color: AppTheme.accentRed),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ride['pickup'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 12),
                                  Text(ride['dropoff'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Text(
                              ride['price'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Driver: ${ride['driver']}',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(index),
                              tooltip: appCopy(context, 'Delete', 'Futa'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
