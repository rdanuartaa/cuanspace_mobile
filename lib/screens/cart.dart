import 'package:flutter/material.dart';
import '../models/product.dart';

class Cart extends StatefulWidget {
  final Product? product;
  final int? quantity;

  Cart({this.product, this.quantity});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  // List untuk menyimpan produk dan jumlahnya di keranjang
  static List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    // Jika ada produk yang dikirim dari halaman detail, tambahkan ke keranjang
    if (widget.product != null && widget.quantity != null) {
      bool found = false;
      for (var item in cartItems) {
        if (item['product'].id == widget.product!.id) {
          item['quantity'] += widget.quantity!;
          found = true;
          break;
        }
      }
      if (!found) {
        cartItems.add({
          'product': widget.product,
          'quantity': widget.quantity,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Keranjang Belanja',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 100,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Keranjang Anda kosong.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final Product product = item['product'];
                final int quantity = item['quantity'];

                return ListTile(
                  leading: Image.network(
                    '${product.thumbnail}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Theme.of(context).colorScheme.secondary,
                      );
                    },
                  ),
                  title: Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    'Jumlah: $quantity',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  trailing: Text(
                    'Rp ${(product.price * quantity).toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
    );
  }
}