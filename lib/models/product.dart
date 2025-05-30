// File: product.dart
import 'kategori.dart';
import '../services/api_service.dart';

class Product {
  final int id;
  final int sellerId;
  final int kategoriId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String digitalFile;
  final String status;
  final int? purchaseCount;
  final int? viewCount;
  final Kategori? kategori;

  Product({
    required this.id,
    required this.sellerId,
    required this.kategoriId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.digitalFile,
    required this.status,
    this.purchaseCount,
    this.viewCount,
    this.kategori,
  });

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    String thumbnail = json['thumbnail']?.toString() ?? '';
    String imageUrl;

    if (thumbnail.startsWith('http')) {
      imageUrl = thumbnail;
    } else if (thumbnail.isNotEmpty) {
      imageUrl = '${ApiService.storageUrl}/$thumbnail';
    } else {
      imageUrl = 'https://via.placeholder.com/300x200';
    }

    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      sellerId: json['seller_id'] is int ? json['seller_id'] : int.tryParse(json['seller_id'].toString()) ?? 0,
      kategoriId: json['kategori_id'] is int ? json['kategori_id'] : int.tryParse(json['kategori_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Product',
      description: json['description']?.toString() ?? '',
      price: json['price'] != null
          ? (json['price'] is String
              ? double.tryParse(json['price']) ?? 0.0
              : (json['price'] as num).toDouble())
          : 0.0,
      image: imageUrl,
      digitalFile: json['digital_file']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      purchaseCount: json['purchase_count'] is int ? json['purchase_count'] : null,
      viewCount: json['view_count'] is int ? json['view_count'] : null,
      kategori: json['kategori'] != null && json['kategori'] is Map
          ? Kategori.fromJson(json['kategori'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'kategori_id': kategoriId,
      'name': name,
      'description': description,
      'price': price,
      'thumbnail': image,
      'digital_file': digitalFile,
      'status': status,
      'purchase_count': purchaseCount,
      'view_count': viewCount,
      'kategori': kategori?.toJson(),
    };
  }
}