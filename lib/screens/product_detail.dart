import 'package:flutter/material.dart';
import 'package:cuan_space/models/product.dart';
import 'package:cuan_space/services/api_service.dart';
import 'package:cuan_space/screens/cart.dart';
import 'package:cuan_space/screens/settings.dart';
import 'package:cuan_space/main.dart';
import 'package:intl/intl.dart';

class ProductDetail extends StatefulWidget {
  final Product product;

  const ProductDetail({super.key, required this.product});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int quantity = 1;
  final ApiService apiService = ApiService();
  List<dynamic> reviews = [];
  bool hasPurchased = false;
  bool isLoadingReviews = true;
  String errorMessage = '';
  bool isOwnProduct = false;

  @override
  void initState() {
    super.initState();
    fetchReviews();
    checkIfOwnProduct();
  }

  Future<void> checkIfOwnProduct() async {
    try {
      final user = await apiService.getCurrentUser();
      setState(() {
        isOwnProduct = user != null &&
            user.id != null &&
            widget.product.sellerId == user.id;
      });
    } catch (e) {
      print('Error checking own product: $e');
      setState(() {
        isOwnProduct = false;
      });
    }
  }

  Future<void> fetchReviews() async {
    final result = await apiService.fetchReviews(widget.product.id);
    setState(() {
      isLoadingReviews = false;
      if (result['success']) {
        reviews = result['data']['reviews'];
        hasPurchased = result['data']['has_purchased'] ?? false;
      } else {
        errorMessage = result['message'];
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  child: Image.network(
                    '${ApiService.storageUrl}/${widget.product.image}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${widget.product.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Jumlah: ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove,
                                color: Theme.of(context).iconTheme.color),
                            onPressed: isOwnProduct
                                ? null
                                : () {
                                    if (quantity > 1) {
                                      setState(() {
                                        quantity--;
                                      });
                                    }
                                  },
                          ),
                          Text(
                            '$quantity',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 16),
                          ),
                          IconButton(
                            icon: Icon(Icons.add,
                                color: Theme.of(context).iconTheme.color),
                            onPressed: isOwnProduct
                                ? null
                                : () {
                                    setState(() {
                                      quantity++;
                                    });
                                  },
                          ),
                        ],
                      ),
                      if (isOwnProduct)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Anda tidak dapat membeli produk Anda sendiri.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '4.9 373 rating • ${reviews.length} ulasan',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Kategori: ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            widget.product.kategori?.namaKategori ??
                                'Tidak diketahui',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Etalase: ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'Semua Etalase',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Deskripsi Produk',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: widget.product.sellerId <= 0
                                ? null
                                : () async {
                                    try {
                                      final result = await apiService
                                          .startChat(widget.product.sellerId);
                                      if (result['success']) {
                                        print(
                                            'Chat started, chat_id: ${result['data']['chat_id']}'); // Debugging
                                        Navigator.pushNamed(context, '/chat',
                                            arguments: {
                                              'chat_id': result['data']
                                                  ['chat_id'],
                                              'seller_id': result['data']
                                                  ['seller_id'],
                                              'seller_name': result['data']
                                                      ['seller_name'] ??
                                                  'Penjual Tidak Diketahui',
                                            });
                                      } else {
                                        print(
                                            'Start chat failed: ${result['message']}'); // Debugging
                                        showFloatingNotification(
                                            result['message']);
                                        if (result['navigateToLogin'] == true) {
                                          Navigator.pushReplacementNamed(
                                              context, '/login');
                                        }
                                      }
                                    } catch (e) {
                                      print(
                                          'Start chat exception: $e'); // Debugging
                                      showFloatingNotification(
                                          'Terjadi kesalahan: $e');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkOrange,
                              foregroundColor: softWhite,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Chat Penjual',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ulasan Produk',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      isLoadingReviews
                          ? Center(
                              child:
                                  CircularProgressIndicator(color: darkOrange))
                          : errorMessage.isNotEmpty
                              ? Center(child: Text(errorMessage))
                              : reviews.isEmpty
                                  ? Center(
                                      child: Text(
                                          'Belum ada ulasan untuk produk ini.'))
                                  : Column(
                                      children: reviews.map((review) {
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      review['user']['name'] ??
                                                          'Anonim',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      children: List.generate(
                                                        review['rating'],
                                                        (index) => Icon(
                                                          Icons.star,
                                                          color: Colors.yellow,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  review['comment'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  DateFormat('dd MMM yyyy')
                                                      .format(
                                                    DateTime.parse(
                                                        review['created_at']),
                                                  ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.7),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                      if (hasPurchased)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Anda telah membeli produk ini. Tambahkan ulasan di halaman transaksi.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.green,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.settings,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Cart()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isOwnProduct
                    ? () {
                        showFloatingNotification(
                            'Anda tidak dapat membeli produk Anda sendiri.');
                      }
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Cart(
                              product: widget.product,
                              quantity: quantity,
                            ),
                          ),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                child: Text(
                  'Keranjang',
                  style: TextStyle(
                    color: isOwnProduct
                        ? Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5)
                        : Theme.of(context).colorScheme.primary,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: isOwnProduct
                    ? () {
                        showFloatingNotification(
                            'Anda tidak dapat membeli produk Anda sendiri.');
                      }
                    : () {
                        // Arahkan ke halaman checkout
                        Navigator.pushNamed(context, '/checkout', arguments: {
                          'product_id': widget.product.id,
                          'product_name': widget.product.name,
                          'price': widget.product.price,
                          'quantity': quantity,
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwnProduct
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                      : Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  'Beli',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}