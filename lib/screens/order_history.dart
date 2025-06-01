import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '/main.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final ApiService apiService = ApiService();
  List<dynamic> transactions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    try {
      final result = await apiService.fetchOrderHistory();
      setState(() {
        if (result['success']) {
          transactions = result['data'] ?? [];
        } else {
          errorMessage = result['message'] ?? 'Gagal memuat riwayat pembelian.';
          if (result['navigateToLogin'] == true) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading order history: $e';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembelian'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkOrange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: darkOrange))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium))
              : transactions.isEmpty
                  ? const Center(
                      child: Text('Belum ada pembelian.',
                          style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final product = transaction['product'];
                        final hasReviewed =
                            transaction['has_reviewed'] ?? false;
                        final downloadCount =
                            transaction['download_count'] ?? 0;
                        final maxDownload = 3;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        '${ApiService.storageUrl}/${product['thumbnail']}',
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      child: const Center(
                                          child: Icon(Icons.broken_image,
                                              size: 50)),
                                    ),
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                          color: darkOrange),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? 'Unknown Product',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              fontFamily: 'Poppins',
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rp ${transaction['amount'].toStringAsFixed(0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: darkOrange,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Kode Transaksi: ${transaction['transaction_code']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Download Button
                                      ElevatedButton(
                                        onPressed: downloadCount < maxDownload
                                            ? () {
                                                Navigator.pushNamed(context,
                                                    '/order-confirmation',
                                                    arguments: {
                                                      'order_id': transaction[
                                                          'transaction_code'],
                                                      'product_name':
                                                          product['name'],
                                                      'quantity': 1,
                                                      'total_price':
                                                          transaction['amount'],
                                                    });
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: darkOrange,
                                          foregroundColor: softWhite,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                        ),
                                        child: Text(
                                          'Download ($downloadCount/$maxDownload)',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      // Review Button
                                      if (!hasReviewed)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/submit_review',
                                                  arguments: {
                                                    'product_id': product['id'],
                                                    'product_name':
                                                        product['name'],
                                                  }).then((_) =>
                                                  fetchOrderHistory()); // Refresh after review
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: softWhite,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                            ),
                                            child: const Text(
                                              'Berikan Ulasan',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        )
                                      else
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: Text(
                                            'Ulasan telah diberikan.',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
