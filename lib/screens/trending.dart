import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cuan_space/bloc/trending/trending_bloc.dart';
import 'package:cuan_space/bloc/trending/trending_event.dart';
import 'package:cuan_space/bloc/trending/trending_state.dart';
import 'package:cuan_space/services/api_service.dart';
import 'package:cuan_space/screens/cart.dart';
import 'package:cuan_space/main.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  int _selectedIndex = 1;
  String _sortBy = 'purchases'; // default diubah jadi 'purchases'

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _sortBy = 'purchases');
                      context
                          .read<TrendingBloc>()
                          .add(const FetchTrendingProducts('purchases'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sortBy == 'purchases'
                          ? darkOrange
                          : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Paling Dibeli',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: BlocBuilder<TrendingBloc, TrendingState>(
                      builder: (context, state) {
                        if (state is TrendingLoading) {
                          return const Center(
                              child:
                                  CircularProgressIndicator(color: darkOrange));
                        } else if (state is TrendingLoaded) {
                          if (state.products.isEmpty) {
                            return const Center(
                                child: Text('Tidak ada produk trending'));
                          }
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: state.products.length,
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              return AnimatedBuilder(
                                animation: CurvedAnimation(
                                  parent: ModalRoute.of(context)?.animation ??
                                      const AlwaysStoppedAnimation(1.0),
                                  curve: Curves.easeInOut,
                                ),
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: CurvedAnimation(
                                      parent:
                                          ModalRoute.of(context)?.animation ??
                                              const AlwaysStoppedAnimation(1.0),
                                      curve: Curves.easeInOut,
                                    ).value,
                                    child: Card(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top: Radius.circular(10)),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '${ApiService.storageUrl}/${product.image}',
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: darkOrange),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(
                                                  Icons.error,
                                                  color: darkOrange,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Dibeli: ${product.purchaseCount}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
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
                                },
                              );
                            },
                          );
                        } else if (state is TrendingError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(state.message),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<TrendingBloc>()
                                        .add(FetchTrendingProducts(_sortBy));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: darkOrange),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          );
                        }
                        return const Center(
                            child: Text('Tekan tombol untuk melihat trending'));
                      },
                    ),
                  ),
                ],
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
              label: 'Trending', // Diubah dari 'Jelajah'
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
