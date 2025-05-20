import 'package:flutter/material.dart';
import 'cart.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  Map<String, dynamic>? aboutData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAboutData();
  }

  // Fungsi untuk menampilkan notifikasi melayang
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Hapus notifikasi setelah 3 detik
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> fetchAboutData() async {
    try {
      // Data statis lokal
      final staticData = {
        'description': 'Kami adalah platform yang berdedikasi untuk memberikan pengalaman terbaik bagi pengguna.',
        'version': '1.0.0',
        'mission': '- Memberikan pengalaman pengguna yang intuitif.\n'
            '- Menyediakan fitur inovatif.\n'
            '- Menjaga privasi dan keamanan data.'
      };
      setState(() {
        aboutData = staticData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
      showFloatingNotification('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 60), // Ruang untuk tombol kembali dan ikon
                          Text(
                            'Tentang Aplikasi Kami',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            aboutData?['description'] ??
                                'Kami adalah platform yang berdedikasi untuk memberikan pengalaman terbaik bagi pengguna.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Versi Aplikasi',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            aboutData?['version'] ?? '1.0.0',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Misi Kami',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            aboutData?['mission'] ??
                                '- Memberikan pengalaman pengguna yang intuitif.\n'
                                    '- Menyediakan fitur inovatif.\n'
                                    '- Menjaga privasi dan keamanan data.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                    ),
          // Tombol Kembali dan Ikon Keranjang
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).iconTheme.color),
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
    );
  }
}