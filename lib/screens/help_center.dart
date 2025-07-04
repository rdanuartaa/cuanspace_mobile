import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/faq.dart';

class HelpCenterPage extends StatefulWidget {
  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  List<Faq>? faqsFromApi;
  List<Map<String, String>> staticFaqs = [
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
  bool isLoading = true;
  String errorMessage = '';
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchFaqs();
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
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> fetchFaqs() async {
    try {
      final response = await apiService.fetchFaqs();
      if (response['success']) {
        setState(() {
          faqsFromApi = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'];
          isLoading = false;
        });
        showFloatingNotification(response['message']);
      }
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
                          SizedBox(height: 60),
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
                          if (staticFaqs.isNotEmpty)
                            ...staticFaqs.map(
                              (faq) => Card(
                                color: Theme.of(context).cardColor,
                                child: ExpansionTile(
                                  title: Text(
                                    faq['question']!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        faq['answer']!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(height: 24),
                          Text(
                            'Pertanyaan Lainnya',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 8),
                          if (faqsFromApi != null && faqsFromApi!.isNotEmpty)
                            ...faqsFromApi!.map(
                              (faq) => Card(
                                color: Theme.of(context).cardColor,
                                child: ExpansionTile(
                                  title: Text(
                                    faq.question,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        faq.answer,
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
                              'Tidak ada FAQ lainnya tersedia saat ini.',
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
                              // Implementasi kontak email
                            },
                          ),
                        ],
                      ),
                    ),
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
        ],
      ),
    );
  }
}