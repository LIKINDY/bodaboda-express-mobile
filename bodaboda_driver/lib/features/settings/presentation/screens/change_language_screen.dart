import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/localization/app_copy.dart';

class ChangeLanguageScreen extends StatelessWidget {
  const ChangeLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appCopy(context, 'Language', 'Lugha')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: AppSettings.instance,
        builder: (context, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(appCopy(context, 'Choose the language for the app', 'Chagua lugha ya kutumia kwenye app'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              for (final option in [('English', 'en'), ('Kiswahili', 'sw')])
                Card(
                  child: RadioListTile<String>(
                    value: option.$2,
                    groupValue: AppSettings.instance.locale.languageCode,
                    title: Text(option.$1),
                    onChanged: (value) {
                      if (value != null) AppSettings.instance.setLanguage(value);
                    },
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(appCopy(context, 'Done', 'Imekamilika')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
