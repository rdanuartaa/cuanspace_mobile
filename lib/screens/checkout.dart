import 'package:flutter/material.dart';
import 'package:cuan_space/services/api_service.dart';
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
    final user = await apiService.getCurrentUser();
    if (user == null || user.id == null) {
      showFloatingNotification('Silakan login terlebih dahulu');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await apiService.createTransaction({
        'product_id': args['product_id'],
        'quantity': args['quantity'],
      });

      if (result['success']) {
        // Placeholder: Tampilkan Midtrans snap popup
        // Contoh: await MidtransSnap.startPayment(snapToken: result['data']['snap_token']);
        Navigator.pushNamed(context, '/order-confirmation', arguments: {
          'order_id': result['data']['transaction_code'],
          'product_name': args['product_name'],
          'quantity': args['quantity'],
          'total_price': args['price'] * args['quantity'],
        });
      } else {
        showFloatingNotification(result['message']);
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
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
                    Text('Harga Satuan: Rp ${args['price'].toStringAsFixed(0)}'),
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
              onPressed: isLoading
                  ? null
                  : () => processPayment(args),
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