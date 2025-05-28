import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'about_us.dart';
import 'settings.dart';
import 'help_center.dart';
import 'cart.dart';
import '/main.dart'; // Import main.dart for color constants

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 3;
  User? user;
  bool isLoading = true;
  final ApiService apiService = ApiService();
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
    fetchUserData();
  }

  void showFloatingNotification(String message) {
    OverlayEntry overlayEntry = OverlayEntry(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                  ),
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

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  Future<void> fetchUserData() async {
    try {
      final result = await apiService.fetchUserProfile();
      if (result['success']) {
        setState(() {
          user = result['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          showFloatingNotification(result['message']);
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showFloatingNotification('Error loading profile: $e');
    }
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Confirm Logout',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 18),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      fontSize: 12,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                setState(() {
                  isLoading = true;
                });
                try {
                  final result = await apiService.logout();
                  setState(() {
                    isLoading = false;
                  });
                  navigator.pushReplacementNamed('/login');
                  showFloatingNotification(
                      result['message'] ?? 'Logout successful.');
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  navigator.pushReplacementNamed('/login');
                  showFloatingNotification(
                      'Logout successful (local session cleared).');
                }
              },
              child: Text(
                'Logout',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: darkOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/explore');
        break;
      case 2:
        Navigator.pushNamed(context, '/notification');
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255), // warna biru
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: darkOrange.withOpacity(0.1),
                        child: user != null &&
                                user!.userDetail?.profilePhoto != null &&
                                user!.userDetail!.profilePhoto!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  '${ApiService.storageUrl}/${user!.userDetail!.profilePhoto}',
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  headers: _token != null
                                      ? {'Authorization': 'Bearer $_token'}
                                      : null,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                        'Error loading profile photo: $error');
                                    return Icon(
                                      Icons.person,
                                      size: 60,
                                      color: darkOrange,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 60,
                                color: darkOrange,
                              ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.name ?? 'Loading...',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Information',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              _buildDetailRow(Icons.phone, 'Phone Number',
                                  user?.userDetail?.phone ?? '-'),
                              _buildDetailRow(Icons.location_on, 'Address',
                                  user?.userDetail?.address ?? '-'),
                              _buildDetailRow(Icons.transgender, 'Gender',
                                  user?.userDetail?.gender ?? '-'),
                              _buildDetailRow(
                                  Icons.calendar_today,
                                  'Date of Birth',
                                  user?.userDetail?.dateOfBirth ?? '-'),
                              _buildDetailRow(Icons.account_balance, 'Religion',
                                  user?.userDetail?.religion ?? '-'),
                              _buildDetailRow(Icons.work, 'Status',
                                  user?.userDetail?.status ?? '-'),
                              const SizedBox(height: 14),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                            context, '/edit_profile',
                                            arguments: user)
                                        .then((updatedUser) {
                                      if (updatedUser != null) {
                                        setState(() {
                                          user = updatedUser as User;
                                        });
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Edit Profile',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Theme.of(context).colorScheme.surface,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.info,
                                color: darkOrange,
                                size: 20,
                              ),
                              title: Text(
                                'About Us',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/about_us');
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.settings,
                                color: darkOrange,
                                size: 20,
                              ),
                              title: Text(
                                'Settings',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/settings');
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.help,
                                color: darkOrange,
                                size: 20,
                              ),
                              title: Text(
                                'Help Center',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/help_center');
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.logout,
                                color: darkOrange,
                                size: 20,
                              ),
                              title: Text(
                                'Logout',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: darkOrange,
                                      fontSize: 13,
                                    ),
                              ),
                              onTap: _logout,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: darkOrange, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.settings, color: darkOrange, size: 20),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined,
                            color: darkOrange, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Cart()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Beranda', // Diubah dari 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, size: 24),
            label: 'Jelajah', // Diubah dari 'Explore'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 24),
            label: 'Notifikasi', // Diubah dari 'Notifications'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Profil', // Diubah dari 'Profile'
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: darkOrange,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: darkOrange,
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
