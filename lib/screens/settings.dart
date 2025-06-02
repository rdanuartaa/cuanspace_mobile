import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cuan_space/services/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguage = 'Indonesia';
  bool notificationsEnabled = true;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void showFloatingNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> loadSettings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        selectedLanguage = prefs.getString('language') ?? 'Indonesia';
        notificationsEnabled = prefs.getBool('notifications') ?? true;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Terjadi kesalahan: $e';
      });
      showFloatingNotification('Terjadi kesalahan: $e');
    }
  }

  Future<void> saveSettings() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', selectedLanguage);
      await prefs.setBool('notifications', notificationsEnabled);
      setState(() {
        isLoading = false;
      });
      showFloatingNotification('Pengaturan berhasil disimpan');
    } catch (e) {
      debugPrint('Error saving settings: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Terjadi kesalahan: $e';
      });
      showFloatingNotification('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Pengaturan',
          style: Theme.of(context).appBarTheme.titleTextStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.dark_mode,
                        color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      'Mode Gelap',
                      style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500) ??
                          const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
