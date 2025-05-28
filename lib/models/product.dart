import 'package:cuan_space/models/kategori.dart';

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
    this.kategori,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      sellerId: json['seller_id'] ?? 0,
      kategoriId: json['kategori_id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      price: json['price'] != null
          ? (json['price'] is String
              ? double.tryParse(json['price']) ?? 0.0
              : (json['price'] as num).toDouble())
          : 0.0,
      image: json['thumbnail'] ?? '', // Menggunakan key 'thumbnail'
      digitalFile: json['digital_file'] ?? '',
      status: json['status'] ?? 'unknown',
      purchaseCount: json['purchase_count'],
      kategori:
          json['kategori'] != null ? Kategori.fromJson(json['kategori']) : null,
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
      'thumbnail': image, // Sesuaikan dengan backend jika perlu
      'digital_file': digitalFile,
      'status': status,
      'purchase_count': purchaseCount,
      'kategori': kategori?.toJson(),
    };
  }
}
