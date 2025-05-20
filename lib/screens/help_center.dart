import 'package:flutter/material.dart';
import 'cart.dart';

class HelpCenterPage extends StatefulWidget {
  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  List<dynamic>? faqs;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchFaqs();
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

  Future<void> fetchFaqs() async {
    try {
      // Data FAQ statis bertema e-commerce digital
      final staticFaqs = [
        {
          'question': 'Bagaimana cara melacak pesanan saya?',
          'answer':
              'Setelah pesanan dikirim, Anda akan menerima nomor pelacakan. Masukkan nomor tersebut di halaman Pelacakan Pesanan untuk melihat status pengiriman.'
        },
        {
          'question': 'Apa metode pembayaran yang diterima?',
          'answer':
              'Kami menerima pembayaran melalui kartu kredit/debit, transfer bank, dompet digital, dan COD (bayar di tempat) di wilayah tertentu.'
        },
        {
          'question': 'Bagaimana cara mengembalikan produk?',
          'answer':
              'Anda dapat mengajukan pengembalian dalam waktu 7 hari setelah menerima produk. Buka halaman Pengembalian, isi formulir, dan ikuti petunjuk untuk pengiriman kembali.'
        },
        {
          'question': 'Berapa lama waktu pengiriman?',
          'answer':
              'Waktu pengiriman tergantung pada lokasi Anda. Umumnya, 2-5 hari kerja untuk pulau Jawa dan 5-10 hari kerja untuk luar Jawa.'
        },
        {
          'question': 'Bagaimana jika produk yang diterima rusak?',
          'answer':
              'Hubungi kami melalui support@ecommerce.com dalam waktu 48 jam setelah menerima produk. Sertakan foto kerusakan untuk proses klaim.'
        }
      ];
      setState(() {
        faqs = staticFaqs;
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
                            'Pusat Bantuan',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Temukan jawaban atas pertanyaan Anda atau hubungi kami.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Pertanyaan Umum (FAQ)',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 8),
                          if (faqs != null && faqs!.isNotEmpty)
                            ...faqs!.map(
                              (faq) => Card(
                                color: Theme.of(context).cardColor,
                                child: ExpansionTile(
                                  title: Text(
                                    faq['question'] ?? 'Pertanyaan',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        faq['answer'] ?? 'Jawaban tidak tersedia',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Text(
                              'Tidak ada FAQ tersedia saat ini.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          SizedBox(height: 24),
                          ListTile(
                            leading: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
                            title: Text(
                              'Hubungi Kami',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            subtitle: Text(
                              'cuanspaceaja@gmail.com',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                            onTap: () {
                              // Implementasi kontak email (misalnya, buka aplikasi email)
                            },
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