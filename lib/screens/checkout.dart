import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cuan_space/services/api_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '/main.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  bool isLoading = false;
  final ApiService apiService = ApiService();

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

  Future<void> processPayment(Map<String, dynamic> args) async {
    try {
      final user = await apiService.getCurrentUser();
      if (user == null || user.id == null) {
        print(
            'Error processPayment: User tidak ditemukan atau sesi tidak valid');
        showFloatingNotification('Silakan login terlebih dahulu');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      print('User ditemukan: ${user.id}, email: ${user.email}');

      setState(() {
        isLoading = true;
      });

      if (args['product_id'] == null || args['quantity'] == null) {
        throw Exception('Data produk atau jumlah tidak valid');
      }

      final result = await apiService.createTransaction({
        'product_id': args['product_id'],
        'quantity': args['quantity'],
        'email': user.email ?? 'user@example.com',
      });

      print('createTransaction result: $result');

      String? snapToken;
      String? transactionCode;

      if (result['success'] == true) {
        snapToken = result['data']['snap_token'];
        transactionCode = result['data']['transaction_code'];
        print('Snap token: $snapToken, Transaction code: $transactionCode');
      } else if (result['data'] != null &&
          result['data']['snap_token'] != null) {
        snapToken = result['data']['snap_token'];
        transactionCode = result['data']['transaction_code'];
        print(
            'Pending transaction found - Snap token: $snapToken, Transaction code: $transactionCode');
        showFloatingNotification(
            'Anda memiliki transaksi yang belum diselesaikan. Silakan selesaikan pembayaran atau batalkan transaksi.');
        final action = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Transaksi Pending'),
            content: const Text(
                'Anda memiliki transaksi yang belum diselesaikan. Apa yang ingin Anda lakukan?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                child: const Text('Batalkan Transaksi'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'continue'),
                child: const Text('Lanjutkan Pembayaran'),
              ),
            ],
          ),
        );

        if (action == 'cancel') {
          await apiService.cancelTransaction(transactionCode!);
          showFloatingNotification('Transaksi pending telah dibatalkan.');
          return processPayment(args); // Ulangi proses pembayaran
        }
      } else {
        print('Error createTransaction: ${result['message']}');
        showFloatingNotification(result['message']);
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      if (snapToken != null && transactionCode != null) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Expanded(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(
                          url: WebUri(
                              'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken')),
                      onLoadStop: (controller, url) async {
                        if (url != null &&
                            url.toString().contains('transaction_status')) {
                          try {
                            final uri = Uri.parse(url.toString());
                            final transactionStatus =
                                uri.queryParameters['transaction_status'];
                            print(
                                'Midtrans transaction status: $transactionStatus');

                            if (transactionStatus != null) {
                              switch (transactionStatus) {
                                case 'settlement':
                                case 'capture':
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, '/order-confirmation',
                                      arguments: {
                                        'order_id': transactionCode,
                                        'product_name': args['product_name'],
                                        'quantity': args['quantity'],
                                        'total_price':
                                            args['price'] * args['quantity'],
                                      });
                                  showFloatingNotification(
                                      'Pembayaran berhasil!');
                                  break;
                                case 'cancel':
                                case 'expire':
                                  Navigator.pop(context);
                                  showFloatingNotification(
                                      'Transaksi dibatalkan atau kedaluwarsa.');
                                  break;
                                case 'deny':
                                  Navigator.pop(context);
                                  showFloatingNotification(
                                      'Pembayaran ditolak.');
                                  break;
                                default:
                                  showFloatingNotification(
                                      'Status transaksi tidak dikenal.');
                              }
                            } else {
                              showFloatingNotification(
                                  'Gagal memproses status transaksi.');
                            }
                          } catch (e) {
                            print('Error parsing transaction status: $e');
                            Navigator.pop(context);
                            showFloatingNotification(
                                'Gagal memproses status transaksi.');
                          }
                        }
                      },
                      onLoadError: (controller, url, code, message) {
                        print('WebView error: $message');
                        Navigator.pop(context);
                        showFloatingNotification(
                            'Gagal memuat halaman pembayaran.');
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showFloatingNotification('Transaksi dibatalkan.');
                    },
                    child: const Text('Batalkan'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error processPayment: $e');
      showFloatingNotification('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final totalPrice = args['price'] * args['quantity'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Pesanan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Produk: ${args['product_name']}'),
                    Text('Jumlah: ${args['quantity']}'),
                    Text(
                        'Harga Satuan: Rp ${args['price'].toStringAsFixed(0)}'),
                    Text('Total: Rp ${totalPrice.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Metode Pembayaran',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Midtrans (Kartu Kredit, Bank Transfer, dll)'),
            const Spacer(),
            ElevatedButton(
              onPressed: isLoading ? null : () => processPayment(args),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkOrange,
                foregroundColor: softWhite,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: softWhite)
                  : const Text(
                      'Bayar Sekarang',
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
