import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cuan_space/services/api_service.dart';
import 'package:cuan_space/models/kategori.dart';
import 'package:cuan_space/models/product.dart';
import 'package:cuan_space/screens/notification.dart';
import 'package:cuan_space/screens/cart.dart';
import 'package:cuan_space/main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Kategori> kategoris = [];
  List<Product> products = [];
  bool isLoading = true;
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final kategoriResult = await _apiService.fetchKategoris();
      if (kategoriResult['navigateToLogin'] == true) {
        Navigator.pushNamed(context, '/login');
        return;
      }

      final productResult = await _apiService.fetchProducts();
      if (productResult['navigateToLogin'] == true) {
        Navigator.pushNamed(context, '/login');
        return;
      }

      setState(() {
        if (kategoriResult['success']) {
          kategoris = kategoriResult['data'] as List<Kategori>;
        }

        if (productResult['success']) {
          products = productResult['data'] as List<Product>;
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/trending');
        break;
      case 2:
        Navigator.pushNamed(context, '/notification');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  List<Product> get filteredProducts {
    var filtered = products;
    if (_selectedCategoryIndex != null) {
      filtered = filtered
          .where((product) =>
              product.kategoriId == kategoris[_selectedCategoryIndex!].id)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery) ||
              product.description.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: darkOrange))
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                'Cuan Space',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search digital products...',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.notifications,
                                    color: darkOrange, size: 20),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/notification');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.shopping_cart_outlined,
                                    color: darkOrange, size: 20),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Cart()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Digital Product Categories',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              kategoris.isEmpty
                                  ? Text(
                                      'No categories available.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                    )
                                  : SizedBox(
                                      height: 40,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: kategoris.length,
                                        itemBuilder: (context, index) {
                                          final isSelected =
                                              _selectedCategoryIndex == index;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    _selectedCategoryIndex =
                                                        null;
                                                  } else {
                                                    _selectedCategoryIndex =
                                                        index;
                                                  }
                                                });
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? darkOrange
                                                          .withOpacity(0.1)
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .surface,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? darkOrange
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.3),
                                                    width: isSelected ? 2 : 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      kategoris[index]
                                                          .namaKategori,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                            color: isSelected
                                                                ? darkOrange
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurface,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      Icons.arrow_drop_down,
                                                      size: 18,
                                                      color: isSelected
                                                          ? darkOrange
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Popular Digital Products',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      filteredProducts.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Text(
                                  'No products available.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 0),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.7,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final product = filteredProducts[index];
                                    return ProductCard(product: product);
                                  },
                                  childCount: filteredProducts.length,
                                ),
                              ),
                            ),
                      const SliverToBoxAdapter(child: SizedBox(height: 14)),
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Theme.of(context).colorScheme.onSurface,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Bintang rating
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < product.averageRating.floor()
                            ? Icons.star
                            : product.averageRating - index >= 0.5
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.orange,
                        size: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${product.reviewCount} ulasan',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontSize: 10,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Rp ${product.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: darkOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
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
