import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 3;
  User? user;
  bool isLoading = true;
  String errorMessage = '';
  final ApiService apiService = ApiService();
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
    fetchUserData();
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
      setState(() {
        if (result['success']) {
          user = result['data'];
        } else {
          errorMessage = result['message'] ?? 'Gagal memuat data pengguna.';
          if (result['navigateToLogin'] == true) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Kesalahan saat memuat profil: $e';
        isLoading = false;
      });
    }
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

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Konfirmasi Logout',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 18),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun Anda?',
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Batal',
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
                  Navigator.pushReplacementNamed(context, '/login');
                  showFloatingNotification(
                      result['message'] ?? 'Logout berhasil.');
                } catch (e) {
                  Navigator.pushReplacementNamed(context, '/login');
                  showFloatingNotification(
                      'Logout berhasil (sesi lokal dihapus).');
                } finally {
                  setState(() {
                    isLoading = false;
                  });
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
        Navigator.pushNamed(context, '/trending');
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: darkOrange))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: darkOrange.withOpacity(0.1),
                              child: user?.userDetail?.profilePhoto != null &&
                                      user!.userDetail!.profilePhoto!.isNotEmpty
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            '${ApiService.storageUrl}/${user!.userDetail!.profilePhoto}',
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.person,
                                          size: 80,
                                          color: darkOrange,
                                        ),
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(
                                                color: darkOrange),
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 80,
                                      color: darkOrange,
                                    ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user?.name ?? 'Pengguna Tidak Diketahui',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.email ?? 'Email tidak tersedia',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Informasi Pribadi
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informasi Pribadi',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  Icons.phone,
                                  'Nomor Telepon',
                                  user?.userDetail?.phone ?? 'Belum diatur',
                                ),
                                _buildDetailRow(
                                  Icons.location_on,
                                  'Alamat',
                                  user?.userDetail?.address ?? 'Belum diatur',
                                ),
                                _buildDetailRow(
                                  Icons.transgender,
                                  'Jenis Kelamin',
                                  user?.userDetail?.gender ?? 'Belum diatur',
                                ),
                                _buildDetailRow(
                                  Icons.calendar_today,
                                  'Tanggal Lahir',
                                  user?.userDetail?.dateOfBirth ??
                                      'Belum diatur',
                                ),
                                _buildDetailRow(
                                  Icons.account_balance,
                                  'Agama',
                                  user?.userDetail?.religion ?? 'Belum diatur',
                                ),
                                _buildDetailRow(
                                  Icons.work,
                                  'Status',
                                  user?.userDetail?.status ?? 'Belum diatur',
                                ),
                                const SizedBox(height: 16),
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkOrange,
                                      foregroundColor: softWhite,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text(
                                      'Edit Profil',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Menu Tambahan
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.history,
                                    color: darkOrange, size: 24),
                                title: Text(
                                  'Riwayat Pembelian',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/order-history');
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.info,
                                    color: darkOrange, size: 24),
                                title: Text(
                                  'Tentang Kami',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/about_us');
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.settings,
                                    color: darkOrange, size: 24),
                                title: Text(
                                  'Pengaturan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/settings');
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.help,
                                    color: darkOrange, size: 24),
                                title: Text(
                                  'Pusat Bantuan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/help_center');
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.logout,
                                    color: darkOrange, size: 24),
                                title: Text(
                                  'Logout',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: darkOrange,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                ),
                                onTap: _logout,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
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
        backgroundColor: Theme.of(context).colorScheme.background,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
        showUnselectedLabels: true,
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: darkOrange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontSize: 13,
                        fontFamily: 'Poppins',
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
