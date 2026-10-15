import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final List<Map<String, String>> _addresses = [
    {'name': 'Home', 'address': '123 Boda Lane, Dar es Salaam'},
    {'name': 'Office', 'address': 'City Center Boda Hub'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Favourite', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ..._addresses.map((addr) => _buildAddressCard(context, addr['name']!, addr['address']!)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              final nameController = TextEditingController();
              final addressController = TextEditingController();
              showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Add a saved place'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                      const SizedBox(height: 12),
                      TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final address = addressController.text.trim();
                        if (name.isEmpty || address.isEmpty) return;
                        Navigator.pop(dialogContext);
                        setState(() => _addresses.add({'name': name, 'address': address}));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo address saved.')));
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ).whenComplete(() {
                nameController.dispose();
                addressController.dispose();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Address'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, String name, String address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(address, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy address',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: '$name: $address'));
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address copied.')));
            },
            icon: const Icon(Icons.copy, color: AppTheme.primaryBlue, size: 18),
          ),
        ],
      ),
    );
  }
}
