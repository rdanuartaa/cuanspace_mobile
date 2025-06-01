import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cuan_space/bloc/trending/trending_bloc.dart';
import 'package:cuan_space/bloc/trending/trending_event.dart';
import 'package:cuan_space/bloc/trending/trending_state.dart';
import 'package:cuan_space/services/api_service.dart';
import 'package:cuan_space/screens/cart.dart';
import 'package:cuan_space/main.dart';

import '../models/product.dart';

class Trending extends StatefulWidget {
  const Trending({super.key});

  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamed(context, '/notification');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrendingBloc(ApiService())
        ..add(const FetchTrendingProducts('purchases')),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Trending Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: darkOrange, size: 20),
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
            Expanded(
              child: BlocBuilder<TrendingBloc, TrendingState>(
                builder: (context, state) {
                  if (state is TrendingLoading) {
                    return const Center(
                        child: CircularProgressIndicator(color: darkOrange));
                  } else if (state is TrendingLoaded) {
                    if (state.products.isEmpty) {
                      return const Center(
                          child: Text('Tidak ada produk trending'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return ProductCard(product: product);
                      },
                    );
                  } else if (state is TrendingError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TrendingBloc>().add(
                                  const FetchTrendingProducts('purchases'));
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: darkOrange),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is TrendingNavigateToLogin) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushNamed(context, '/login');
                    });
                    return const Center(
                        child: Text('Mengalihkan ke halaman login...'));
                  }
                  return const Center(
                      child: Text('Gagal memuat produk trending'));
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore, size: 24),
              label: 'Trending',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, size: 24),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 24),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: darkOrange,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.surface,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 4,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product_detail',
          arguments: product,
        );
      },
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: (context, url, error) {
                    return Container(
                      color: Theme.of(context).colorScheme.background,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Gambar gagal dimuat',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: darkOrange),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.formattedPrice,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: darkOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Dibeli: ${product.transactionCount ?? 0}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
