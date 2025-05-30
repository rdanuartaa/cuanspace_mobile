import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/seller.dart';

class SellerProfileScreen extends StatefulWidget {
  final int sellerId;
  final String sellerName;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? sellerData;
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
        sellerData = result['data'];
      } else {
        errorMessage = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sellerName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : sellerData != null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sellerData!['brand_name'] ?? 'Nama Tidak Diketahui',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(sellerData!['description'] ?? ''),
                          const SizedBox(height: 8),
                          Text('Alamat: ${sellerData!['address'] ?? ''}'),
                          Text('Email: ${sellerData!['contact_email'] ?? ''}'),
                          Text('WhatsApp: ${sellerData!['contact_whatsapp'] ?? ''}'),
                        ],
                      ),
                    )
                  : const Center(child: Text('Data penjual tidak tersedia')),
    );
  }
}