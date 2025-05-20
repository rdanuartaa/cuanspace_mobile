import 'kategori.dart';

class Product {
  final int id;
  final int sellerId;
  final int kategoriId;
  final String name;
  final String description;
  final double price;
  final String thumbnail;
  final String digitalFile;
  final String status;
  final Kategori? kategori;

  Product({
    required this.id,
    required this.sellerId,
    required this.kategoriId,
    required this.name,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.digitalFile,
    required this.status,
    this.kategori,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      sellerId: json['seller_id'],
      kategoriId: json['kategori_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      thumbnail: json['thumbnail'],
      digitalFile: json['digital_file'],
      status: json['status'],
      kategori: json['kategori'] != null ? Kategori.fromJson(json['kategori']) : null,
    );
  }
}