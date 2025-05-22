import 'package:flutter/material.dart';
import '../models/product.dart';
import '/main.dart'; // Import main.dart for color constants

class Cart extends StatefulWidget {
  final Product? product;
  final int? quantity;

  Cart({this.product, this.quantity});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  static List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
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

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      final newQuantity = cartItems[index]['quantity'] + change;
      if (newQuantity > 0) {
        cartItems[index]['quantity'] = newQuantity;
      } else {
        _removeItem(index);
      }
    });
  }

  double _calculateTotalPrice() {
    return cartItems.fold(0.0, (total, item) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      return total + (product.price * quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
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
                    color: lightGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to your cart to proceed.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final Product product = item['product'];
                      final int quantity = item['quantity'];

                      return Card(
                        color: Theme.of(context).colorScheme.surface,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Image.network(
                            '${product.thumbnail}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                size: 50,
                                color: lightGrey,
                              );
                            },
                          ),
                          title: Text(
                            product.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${product.price.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: darkOrange,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: () => _updateQuantity(index, -1),
                                    color: darkOrange,
                                  ),
                                  Text(
                                    '$quantity',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () => _updateQuantity(index, 1),
                                    color: darkOrange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: darkOrange),
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Price:',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'Rp ${_calculateTotalPrice().toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  color: darkOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Placeholder for checkout navigation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Proceeding to checkout...')),
                            );
                            // Navigator.pushNamed(context, '/checkout'); // Uncomment when route is defined
                          },
                          child: const Text('Checkout'),
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