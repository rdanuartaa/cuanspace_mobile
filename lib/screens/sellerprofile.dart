import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/seller.dart';

class SellerProfileScreen extends StatefulWidget {
  final int sellerId;
  final String sellerName;

  SellerProfileScreen({required this.sellerId, required this.sellerName});

  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final ApiService apiService = ApiService();
  Seller? seller;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSellerProfile();
  }

  Future<void> fetchSellerProfile() async {
    final result = await apiService.fetchSellerProfile(widget.sellerId);
    setState(() {
      isLoading = false;
      if (result['success']) {
        seller = result['data'];
      } else {
        errorMessage = result['message'];
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Seller: ${seller?.brandName ?? widget.sellerName}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nama Brand: ${seller!.brandName}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Deskripsi: ${seller!.description}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Alamat: ${seller!.address}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await apiService.startChat(widget.sellerId);
                          if (result['success']) {
                            Navigator.pushNamed(context, '/chat', arguments: {
                              'chat_id': result['data']['chat_id'],
                              'seller_id': result['data']['seller_id'],
                              'seller_name': seller?.brandName ?? widget.sellerName,
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                            if (result['navigateToLogin'] == true) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          }
                        },
                        child: Text('Mulai Percakapan'),
                      ),
                    ],
                  ),
                ),
    );
  }
}