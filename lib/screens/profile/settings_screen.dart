import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/services/language_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(langProvider.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(langProvider.t('language')),
            trailing: DropdownButton<String>(
              value: langProvider.languageCode,
              items: const [
                DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) langProvider.setLanguage(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
