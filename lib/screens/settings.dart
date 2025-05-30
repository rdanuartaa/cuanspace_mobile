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
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium ??
                  const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> loadSettings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      final prefs = await SharedPreferences.getInstance();
      debugPrint('Loaded language: ${prefs.getString('language')}');
      debugPrint('Loaded notifications: ${prefs.getBool('notifications')}');
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
                    leading: Icon(Icons.language,
                        color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      'Bahasa',
                      style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500) ??
                          const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: DropdownButton<String>(
                      value: selectedLanguage,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: Theme.of(context).textTheme.bodyMedium,
                      items: ['Indonesia', 'English'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedLanguage = value;
                          });
                          saveSettings();
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications,
                        color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      'Notifikasi',
                      style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500) ??
                          const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Switch(
                      value: notificationsEnabled,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                        saveSettings();
                      },
                    ),
                  ),
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
