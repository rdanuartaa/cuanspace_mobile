import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cart.dart';
import '/main.dart'; // Import main.dart for color constants

class Notification extends StatefulWidget {
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  int _selectedIndex = 2;
  List<dynamic> notifications = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchNotifications();
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

  Future<void> fetchNotifications() async {
    try {
      final result = await apiService.fetchNotifications();
      if (result['success']) {
        setState(() {
          notifications = result['data'];
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
      showFloatingNotification('Failed to load notifications: $e');
    }
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
        Navigator.pushNamed(context, '/profile');
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
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
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
                isLoading
                    ? Center(child: CircularProgressIndicator(color: darkOrange))
                    : notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 70,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No Notifications',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Notifications will appear here when available.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return Card(
                                color: Theme.of(context).colorScheme.surface,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(10),
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.background,
                                    child: Icon(
                                      notification['type'] == 'promo'
                                          ? Icons.local_offer
                                          : notification['type'] == 'chat'
                                              ? Icons.message
                                              : Icons.info,
                                      color: darkOrange,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    notification['title'],
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 3),
                                      Text(
                                        notification['description'],
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                              fontSize: 11,
                                            ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        notification['time'],
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                              fontSize: 11,
                                            ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {},
                                ),
                              );
                            },
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
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart_outlined, color: darkOrange, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Cart()),
                      );
                    },
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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, size: 24),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 24),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Profile',
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
}