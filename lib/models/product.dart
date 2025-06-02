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
  final int? transactionCount;
  final Kategori? kategori;
  final double averageRating;
  final int reviewCount;

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
    this.transactionCount,
    this.kategori,
    this.averageRating = 0.0,
    this.reviewCount = 0,
  });

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['thumbnail']?.toString() ?? 'https://via.placeholder.com/300x200';

    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      sellerId: json['seller_id'] is int ? json['seller_id'] : int.tryParse(json['seller_id'].toString()) ?? 0,
      kategoriId: json['kategori_id'] is int ? json['kategori_id'] : int.tryParse(json['kategori_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Product',
      description: json['description']?.toString() ?? '',
      price: json['price'] != null
          ? (json['price'] is String
              ? double.tryParse(json['price']) ?? 0.0
              : (json['price'] is num ? json['price'].toDouble() : 0.0))
          : 0.0,
      image: imageUrl,
      digitalFile: json['digital_file']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      transactionCount: json['transaction_count'] != null
          ? (json['transaction_count'] is String
              ? int.tryParse(json['transaction_count']) ?? 0
              : json['transaction_count'] is num ? json['transaction_count'].toInt() : 0)
          : 0,
      kategori: json['kategori'] != null && json['kategori'] is Map
          ? Kategori.fromJson(json['kategori'] as Map<String, dynamic>)
          : null,
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] is String
              ? double.tryParse(json['average_rating']) ?? 0.0
              : json['average_rating'] is num ? json['average_rating'].toDouble() : 0.0)
          : 0.0,
      reviewCount: json['review_count'] != null
          ? (json['review_count'] is String
              ? int.tryParse(json['review_count']) ?? 0
              : json['review_count'] is num ? json['review_count'].toInt() : 0)
          : 0,
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
      'transaction_count': transactionCount,
      'kategori': kategori?.toJson(),
      'average_rating': averageRating,
      'review_count': reviewCount,
    };
  }
}