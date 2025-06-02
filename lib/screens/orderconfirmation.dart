import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cuan_space/services/api_service.dart';
import '/main.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class OrderConfirmation extends StatefulWidget {
  const OrderConfirmation({super.key});

  @override
  _OrderConfirmationState createState() => _OrderConfirmationState();
}

class _OrderConfirmationState extends State<OrderConfirmation> {
  bool isDownloading = false;
  bool isSyncing = false;
  final ApiService apiService = ApiService();
  int downloadCount = 0; // Menyimpan jumlah download
  int maxDownload = 3; // Batas maksimum download
  bool isLoadingDownloadCount = true; // Status pemuatan jumlah download
  String? errorMessage; // Menyimpan pesan error jika ada

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchDownloadCount(); // Panggil di didChangeDependencies untuk memastikan context tersedia
  }

  Future<void> fetchDownloadCount() async {
    setState(() {
      isLoadingDownloadCount = true;
      errorMessage = null;
    });

    try {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final transactionCode = args['order_id'];
      final transactionsResponse = await apiService.fetchOrderHistory();
      if (transactionsResponse['success']) {
        final transactions = transactionsResponse['data'] as List<dynamic>;
        final matchingTransaction = transactions.firstWhere(
          (transaction) => transaction['transaction_code'] == transactionCode,
          orElse: () =>
              <String, dynamic>{}, // Kembalikan Map<String, dynamic> kosong
        );
        if (matchingTransaction.isNotEmpty) {
          setState(() {
            downloadCount = matchingTransaction['download_count'] ?? 0;
            isLoadingDownloadCount = false;
          });
        } else {
          setState(() {
            errorMessage = 'Transaksi tidak ditemukan.';
            isLoadingDownloadCount = false;
          });
        }
      } else {
        setState(() {
          errorMessage = transactionsResponse['message'] ??
              'Gagal memuat riwayat transaksi.';
          isLoadingDownloadCount = false;
        });
      }
    } catch (e) {
      print('Error fetching download count: $e');
      setState(() {
        errorMessage = 'Gagal memuat jumlah download: $e';
        isLoadingDownloadCount = false;
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
              style: Theme.of(context).textTheme.bodyMedium,
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

  Future<void> downloadFile(String transactionCode) async {
    setState(() {
      isDownloading = true;
    });
    try {
      // Panggil fungsi download dari ApiService
      await apiService.downloadFile(transactionCode);

      // Setelah download berhasil, perbarui downloadCount
      setState(() {
        downloadCount =
            downloadCount < maxDownload ? downloadCount + 1 : downloadCount;
      });
      showFloatingNotification('File berhasil diunduh ke folder Download.');

      // Refresh jumlah download dari server untuk memastikan sinkronisasi
      await fetchDownloadCount();
    } catch (e) {
      showFloatingNotification('Gagal mengunduh file: $e');
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> syncTransactionStatus(String transactionCode) async {
    setState(() {
      isSyncing = true;
    });

    try {
      final token = await apiService.getToken();
      if (token == null) {
        showFloatingNotification('Silakan login terlebih dahulu.');
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      for (int attempt = 1; attempt <= 5; attempt++) {
        final response = await http.get(
          Uri.parse(
              '${ApiService.baseUrl}/transactions/$transactionCode/status'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        print(
            'Respons sinkronisasi status (percobaan $attempt): ${response.statusCode}, isi: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] && data['status'] == 'paid') {
            showFloatingNotification(
                'Status transaksi diperbarui menjadi paid.');
            Navigator.pushNamed(context, '/order-confirmation', arguments: {
              'order_id': transactionCode,
              'product_name': 'Produk Tidak Diketahui',
              'quantity': 1,
              'total_price': 0,
            });
            return;
          }
        }

        if (attempt < 5) {
          await Future.delayed(Duration(seconds: 3));
        }
      }

      showFloatingNotification(
          'Transaksi belum dibayar atau status tidak dikenal.');
    } catch (e) {
      print('Error saat menyinkronkan status transaksi: $e');
      showFloatingNotification('Gagal memeriksa status transaksi: $e');
    } finally {
      setState(() {
        isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    print('OrderConfirmation received order_id: ${args['order_id']}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan Berhasil!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID Pesanan: ${args['order_id']}'),
                    Text('Produk: ${args['product_name']}'),
                    Text('Jumlah: ${args['quantity']}'),
                    Text('Total: Rp ${args['total_price'].toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    isLoadingDownloadCount
                        ? const CircularProgressIndicator(color: darkOrange)
                        : errorMessage != null
                            ? Text(
                                errorMessage!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.red),
                              )
                            : Text(
                                'Jumlah Download: $downloadCount/$maxDownload',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: downloadCount >= maxDownload
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                              ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Informasi Download',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'File akan tersedia untuk diunduh sebanyak maksimal 3 kali.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  isDownloading || isSyncing || downloadCount >= maxDownload
                      ? null
                      : () => downloadFile(args['order_id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkOrange,
                foregroundColor: softWhite,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isDownloading || isSyncing
                  ? const CircularProgressIndicator(color: softWhite)
                  : Text(
                      'Unduh File ($downloadCount/$maxDownload)',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
