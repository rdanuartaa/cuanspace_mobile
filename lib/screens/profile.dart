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
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 2;
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
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: lightGrey,
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
                  showFloatingNotification(result['message'] ?? 'Logout successful.');
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  navigator.pushReplacementNamed('/login');
                  showFloatingNotification('Logout successful (local session cleared).');
                }
              },
              child: Text(
                'Logout',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: darkOrange,
                      fontWeight: FontWeight.bold,
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
        break;
      case 3:
        Navigator.pushNamed(context, '/notification');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: darkOrange.withOpacity(0.1),
                  child: user != null &&
                          user!.userDetail?.profilePhoto != null &&
                          user!.userDetail!.profilePhoto!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            '${ApiService.storageUrl}/${user!.userDetail!.profilePhoto}',
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading profile photo: $error');
                              return Icon(
                                Icons.person,
                                size: 70,
                                color: darkOrange,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 70,
                          color: darkOrange,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Loading...',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 18,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(Icons.phone, 'Phone Number', user?.userDetail?.phone ?? '-'),
                        _buildDetailRow(Icons.location_on, 'Address', user?.userDetail?.address ?? '-'),
                        _buildDetailRow(Icons.transgender, 'Gender', user?.userDetail?.gender ?? '-'),
                        _buildDetailRow(
                            Icons.calendar_today, 'Date of Birth', user?.userDetail?.dateOfBirth ?? '-'),
                        _buildDetailRow(Icons.account_balance, 'Religion', user?.userDetail?.religion ?? '-'),
                        _buildDetailRow(Icons.work, 'Status', user?.userDetail?.status ?? '-'),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/edit_profile', arguments: user).then((updatedUser) {
                                if (updatedUser != null) {
                                  setState(() {
                                    user = updatedUser as User;
                                  });
                                }
                              });
                            },
                            child: Text(
                              'Edit Profile',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.info,
                          color: darkOrange,
                        ),
                        title: Text(
                          'About Us',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
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
                        ),
                        title: Text(
                          'Settings',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
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
                        ),
                        title: Text(
                          'Help Center',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
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
                        ),
                        title: Text(
                          'Logout',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: darkOrange,
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
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: darkOrange),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.settings, color: darkOrange),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: darkOrange),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, size: 28),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 28),
            label: 'Notifications',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: darkOrange,
        unselectedItemColor: pureBlack,
        selectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: darkOrange,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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