class Kategori {
  final int id;
  final String namaKategori;
  final String? slug;

  Kategori({
    required this.id,
    required this.namaKategori,
    this.slug,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'] ?? 0,
      namaKategori: json['nama_kategori'] ?? '',
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kategori': namaKategori,
      'slug': slug,
    };
  }
}
