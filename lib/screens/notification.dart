import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/chat.dart';
import '/main.dart';

class Notification extends StatefulWidget {
  const Notification({super.key});

  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notification>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  List<dynamic> notifications = [];
  List<Chat> chats = [];
  bool isLoadingNotifications = true;
  bool isLoadingChats = true;
  final ApiService apiService = ApiService();
  Timer? _pollingTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchNotifications();
    fetchChats();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        fetchNotifications(silent: true);
        fetchChats(silent: true);
      }
    });
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

  Future<void> fetchNotifications({bool silent = false}) async {
    try {
      final result = await apiService.fetchNotifications();
      if (result['success']) {
        final newNotifications = result['data'];
        if (!_isNotificationsEqual(notifications, newNotifications)) {
          setState(() {
            notifications = newNotifications;
            if (!silent) isLoadingNotifications = false;
          });
        }
      } else {
        setState(() {
          if (!silent) isLoadingNotifications = false;
        });
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        } else if (!silent) {
          showFloatingNotification(result['message']);
        }
      }
    } catch (e) {
      setState(() {
        if (!silent) isLoadingNotifications = false;
      });
      if (!silent) {
        showFloatingNotification('Gagal memuat notifikasi: $e');
      }
    }
  }

  bool _isNotificationsEqual(List<dynamic> oldList, List<dynamic> newList) {
    if (oldList.length != newList.length) return false;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i]['id'] != newList[i]['id'] ||
          oldList[i]['read'] != newList[i]['read']) {
        return false;
      }
    }
    return true;
  }

  Future<void> fetchChats({bool silent = false}) async {
    try {
      final result = await apiService.fetchChats();
      if (result['success']) {
        setState(() {
          chats = result['data'];
          if (!silent) isLoadingChats = false;
        });
      } else {
        setState(() {
          if (!silent) isLoadingChats = false;
        });
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        } else if (!silent) {
          showFloatingNotification(result['message']);
        }
      }
    } catch (e) {
      setState(() {
        if (!silent) isLoadingChats = false;
      });
      if (!silent) {
        showFloatingNotification('Gagal memuat daftar chat: $e');
      }
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
    print('Notifications di build: $notifications');
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi & Pesan',
            style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: darkOrange,
        bottom: TabBar(
          controller: _tabController,
          labelColor: softWhite,
          unselectedLabelColor: softWhite.withOpacity(0.7),
          indicatorColor: softWhite,
          tabs: const [
            Tab(text: 'Notifikasi'),
            Tab(text: 'Pesan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Notifikasi
          isLoadingNotifications
              ? Center(child: CircularProgressIndicator(color: darkOrange))
              : notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 70,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Tidak Ada Notifikasi',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Notifikasi akan muncul di sini saat tersedia.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
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
                        if (notification['title'] == null || notification['description'] == null) {
                          return ListTile(
                            title: Text('Notifikasi Tidak Valid'),
                            subtitle: Text('Data tidak lengkap'),
                          );
                        }
                        IconData icon;
                        Color iconColor = darkOrange;
                        switch (notification['type'] ?? 'unknown') {
                          case 'chat':
                            icon = Icons.message;
                            break;
                          case 'seller':
                            icon = Icons.store;
                            break;
                          case 'pengguna':
                            icon = Icons.person;
                            break;
                          case 'khusus':
                            icon = Icons.star;
                            break;
                          default:
                            icon = Icons.info;
                        }
                        if (notification['status'] == 'draft' || notification['read'] == true) {
                          iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
                        }

                        String formattedTime = 'Waktu tidak tersedia';
                        if (notification['time'] != null && notification['time'].isNotEmpty) {
                          try {
                            final dateTime = DateTime.parse(notification['time']);
                            formattedTime = DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
                          } catch (e) {
                            print('Error parsing notification time: ${notification['time']}');
                          }
                        }

                        return Card(
                          color: Theme.of(context).colorScheme.surface,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.background,
                              child: Icon(icon, color: iconColor, size: 20),
                            ),
                            title: Text(
                              notification['title']?.toString() ?? 'Tanpa Judul',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: notification['status'] == 'draft' || notification['read'] == true
                                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 3),
                                Text(
                                  notification['description']?.toString() ?? 'Tanpa Pesan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  formattedTime,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                ),
                                if (notification['status'] != 'terkirim')
                                  Text(
                                    'Status: ${notification['status']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                  ),
                              ],
                            ),
                            trailing: notification['read'] == true
                                ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                                : IconButton(
                                    icon: Icon(Icons.circle, color: Colors.blue, size: 20),
                                    onPressed: () async {
                                      final result = await apiService.markNotificationAsRead(notification['id']);
                                      if (result['success']) {
                                        setState(() {
                                          notification['read'] = true;
                                        });
                                        showFloatingNotification('Notifikasi ditandai sebagai dibaca.');
                                      } else {
                                        showFloatingNotification(result['message']);
                                        if (result['navigateToLogin'] == true) {
                                          Navigator.pushReplacementNamed(context, '/login');
                                        }
                                      }
                                    },
                                  ),
                            onTap: () {
                              if (notification['chat_id'] != null && notification['chat_id'] != 0) {
                                Navigator.pushNamed(context, '/chat', arguments: {
                                  'chat_id': notification['chat_id'],
                                  'seller_id': notification['seller_id'] ?? 0,
                                  'seller_name': notification['seller_id'] != null ? 'Seller' : 'Unknown',
                                });
                              } else {
                                showFloatingNotification('Detail: ${notification['description']}');
                              }
                            },
                          ),
                        );
                      },
                    ),

          // Tab Pesan (ChatList)
          isLoadingChats
              ? Center(child: CircularProgressIndicator(color: darkOrange))
              : chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message,
                            size: 70,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Tidak Ada Pesan',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Mulai percakapan dengan seller di sini.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        String formattedTime = 'Waktu tidak tersedia';
                        if (chat.lastMessageTime.isNotEmpty) {
                          try {
                            final dateTime = DateTime.parse(chat.lastMessageTime);
                            formattedTime = DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
                          } catch (e) {
                            print('Error parsing chat lastMessageTime: ${chat.lastMessageTime}');
                          }
                        }
                        return Card(
                          color: Theme.of(context).colorScheme.surface,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.background,
                              child: Icon(
                                Icons.store,
                                color: darkOrange,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              chat.sellerName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dari: ${chat.senderName}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                ),
                                Text(
                                  chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Belum ada pesan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: Text(
                              formattedTime,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/chat', arguments: {
                                'chat_id': chat.id,
                                'seller_id': chat.sellerId,
                                'seller_name': chat.sellerName,
                              });
                            },
                          ),
                        );
                      },
                    ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, size: 24),
            label: 'Jelajah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 24),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Profil',
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

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }
}