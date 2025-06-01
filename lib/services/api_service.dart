import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kategori.dart';
import '../models/massage.dart';
import '../models/product.dart';
import '../models/seller.dart';
import '../models/user_model.dart';
import '../models/chat.dart';
import '../models/faq.dart';

class ApiService {
  // static const String baseUrl = 'http://localhost:8000/api';
  // static const String storageUrl = 'http://localhost:8000/storage';
  // static const String baseUrl = 'http://192.168.1.4:8000/api';
  // static const String storageUrl = 'http://192.168.1.4:8000/storage';
  // static const String baseUrl = 'http:/10.0.0.2:8000/api';
  // static const String storageUrl = 'http://10.0.0.2:8000/storage';
  static const String baseUrl =
      'https://9752-125-166-116-129.ngrok-free.app/api';
  static const String storageUrl =
      'https://9752-125-166-116-129.ngrok-free.app/storage';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print(
          'Login response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['token'];
        final user = data['data']['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token); // Pastikan token disimpan
        await prefs.setString('user', jsonEncode(user)); // Simpan data user
        print('Token saved: $token');
        return {
          'success': true,
          'message': 'Login berhasil',
          'data': data['data'],
        };
      } else {
        final data = jsonDecode(response.body);
        print('Login error: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      print('Login exception: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      print('Status respons registrasi: ${response.statusCode}');
      print('Isi respons registrasi: ${response.body}');

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return {
            'success': true,
            'message': 'Registrasi berhasil.',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Registrasi gagal.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Kesalahan server: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat registrasi: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/password/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      print('Status respons lupa kata sandi: ${response.statusCode}');
      print('Isi respons lupa kata sandi: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ??
              'Permintaan reset kata sandi telah dikirim.',
        };
      } else {
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['email']?[0] ?? 'Gagal mengirim permintaan.',
        };
      }
    } catch (e) {
      print('Kesalahan saat lupa kata sandi: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword(String email, String otp,
      String password, String passwordConfirmation) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('Status respons reset kata sandi: ${response.statusCode}');
      print('Isi respons reset kata sandi: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Kata sandi berhasil direset.',
        };
      } else {
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['email']?[0] ?? 'Gagal mereset kata sandi.',
        };
      }
    } catch (e) {
      print('Kesalahan saat reset kata sandi: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fetch Home Data
  Future<Map<String, dynamic>> fetchHomeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.get(
        Uri.parse('$baseUrl/data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons ambil data beranda: ${response.statusCode}');
      print('Isi respons ambil data beranda: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat data.',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil data beranda: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fetch Products with Filters
  Future<Map<String, dynamic>> fetchProductsFiltered({
    String? kategori,
    String? searchQuery,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      // Build query params
      final Map<String, String> queryParams = {};
      if (kategori != null && kategori != 'all') {
        queryParams['kategori'] = kategori;
      }
      if (searchQuery?.isNotEmpty == true) {
        queryParams['search'] = searchQuery!;
      }

      final uri =
          Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);

      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons ambil produk: ${response.statusCode}');
      print('Isi respons ambil produk: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['data'] == null || responseData['data'].isEmpty) {
          return {
            'success': true,
            'data': [],
            'message': 'Tidak ada produk tersedia.',
          };
        }

        List<Product> products =
            (responseData['data'] as List<dynamic>).map((json) {
          if (json is Map<String, dynamic>) {
            final productJson = json;

            // Add full image URL if thumbnail exists
            if (productJson['thumbnail'] != null &&
                !productJson['thumbnail'].toString().startsWith('http')) {
              productJson['image'] = '$storageUrl/${productJson['thumbnail']}';
            } else {
              productJson['image'] = 'https://via.placeholder.com/300x200';
            }

            return Product.fromJson(productJson);
          }
          throw FormatException('Data produk tidak valid: $json');
        }).toList();

        return {
          'success': true,
          'data': products,
          'message': 'Produk berhasil diambil.',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat produk: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil produk: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fetch Kategoris
  Future<Map<String, dynamic>> fetchKategoris() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Error: Token tidak ditemukan');
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.get(
        Uri.parse('$baseUrl/kategoris'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons ambil kategori: ${response.statusCode}');
      print('Isi respons ambil kategori: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success'] != true) {
          print('Error: Respons API tidak sukses - ${responseData['message']}');
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal memuat kategori.',
          };
        }

        if (responseData['data'] == null || responseData['data'].isEmpty) {
          print('Warning: Data kategori kosong');
          return {
            'success': true,
            'data': [],
            'message': 'Tidak ada kategori tersedia.',
          };
        }

        List<Kategori> kategoris =
            (responseData['data'] as List<dynamic>).map((json) {
          if (json is Map<String, dynamic>) {
            return Kategori.fromJson(json);
          }
          print('Error: Data kategori tidak valid - $json');
          throw FormatException('Data kategori tidak valid: $json');
        }).toList();
        return {
          'success': true,
          'data': kategoris,
          'message': 'Kategori berhasil diambil.',
        };
      } else {
        print('Error: Status code ${response.statusCode}');
        return {
          'success': false,
          'message': 'Gagal memuat kategori: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil kategori: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');
      int? userId;
      String? userRole;

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        userId = userData['id'] != null
            ? int.tryParse(userData['id'].toString())
            : null;
        userRole = userData['role']?.toString(); // Ambil role dari user data
      }

      if (token == null) {
        print('Error: Token tidak ditemukan');
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons ambil produk: ${response.statusCode}');
      print('Isi respons ambil produk: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success'] != true) {
          print('Error: Respons API tidak sukses - ${responseData['message']}');
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal memuat produk.',
          };
        }

        if (responseData['data'] == null || responseData['data'].isEmpty) {
          print('Warning: Data produk kosong');
          return {
            'success': true,
            'data': [],
            'message': 'Tidak ada produk tersedia.',
          };
        }

        List<Product> products =
            (responseData['data'] as List<dynamic>).map((json) {
          if (json is Map<String, dynamic>) {
            print('Parsing produk: $json');
            var productJson = json;
            if (productJson['thumbnail'] != null &&
                !productJson['thumbnail'].startsWith('http')) {
              productJson['thumbnail'] =
                  '$storageUrl/${productJson['thumbnail']}';
            } else if (productJson['thumbnail'] == null) {
              productJson['thumbnail'] = 'https://via.placeholder.com/300x200';
            }
            return Product.fromJson(productJson);
          }
          print('Error: Data produk tidak valid - $json');
          throw FormatException('Data produk tidak valid: $json');
        }).where((product) {
          // Hanya filter produk milik seller jika pengguna adalah seller
          if (userRole == 'seller' && userId != null) {
            return product.sellerId != userId;
          }
          return true; // Tidak ada filter untuk role user
        }).toList();

        return {
          'success': true,
          'data': products,
          'message': 'Produk berhasil diambil.',
        };
      } else {
        print('Error: Status code ${response.statusCode}');
        return {
          'success': false,
          'message': 'Gagal memuat produk: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil produk: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('Error getCurrentUser: Token tidak ditemukan');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(
          'getCurrentUser response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return User.fromMap(data['data']);
        } else {
          print(
              'Error getCurrentUser: Respons API tidak sukses - ${data['message']}');
          return null;
        }
      } else if (response.statusCode == 401) {
        print('Error getCurrentUser: Token tidak valid atau sesi kedaluwarsa');
        return null;
      } else {
        print('Error getCurrentUser: Status code ${response.statusCode}');
        throw Exception(
            'Gagal mengambil data pengguna: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error getCurrentUser: $e');
      throw Exception('Terjadi kesalahan saat mengambil data pengguna: $e');
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required int productId,
    required int quantity,
    required double totalPrice,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Silakan login terlebih dahulu',
          'navigateToLogin': true,
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
          'total_price': totalPrice,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': {
            'order_id': data['data']['order_id'],
            'message': 'Pembelian berhasil',
          },
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memproses pembelian',
          'navigateToLogin': response.statusCode == 401,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Retrieved token: $token');
    return token;
  }

  // Fetch User Profile
  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons ambil profil pengguna: ${response.statusCode}');
      print('Isi respons ambil profil pengguna: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Data pengguna sebelum parsing: $responseData'); // Debugging

        final user = User.fromMap(responseData as Map<String, dynamic>);
        return {
          'success': true,
          'data': user,
          'is_seller': responseData['is_seller'] ?? false,
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat data profil. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil profil pengguna: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fetch FAQs
  Future<Map<String, dynamic>> fetchFaqs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.get(
        Uri.parse('$baseUrl/faqs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons ambil FAQ: ${response.statusCode}');
      print('Isi respons ambil FAQ: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List<Faq> faqs = (responseData['data'] as List)
            .map((json) => Faq.fromJson(json))
            .toList();
        return {
          'success': true,
          'data': faqs,
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat FAQ.',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil FAQ: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? gender,
    String? dateOfBirth,
    String? religion,
    String? status,
    String? profilePhotoPath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      if (name != null) request.fields['name'] = name;
      if (email != null) request.fields['email'] = email;
      if (phone != null) request.fields['phone'] = phone;
      if (address != null) request.fields['address'] = address;
      if (gender != null) request.fields['gender'] = gender;
      if (dateOfBirth != null) request.fields['date_of_birth'] = dateOfBirth;
      if (religion != null) request.fields['religion'] = religion;
      if (status != null) request.fields['status'] = status;

      if (profilePhotoPath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_photo',
          profilePhotoPath,
        ));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Status respons perbarui profil: ${response.statusCode}');
      print('Isi respons perbarui profil: $responseBody');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(responseBody);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profil berhasil diperbarui.',
          'data': User.fromMap(responseData['data']),
        };
      } else {
        var responseData = jsonDecode(responseBody);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memperbarui profil.',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      print('Kesalahan saat perbarui profil: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fetch Seller Profile
  Future<Map<String, dynamic>> fetchSellerProfile(int sellerId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/sellers/$sellerId'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final data = jsonDecode(response.body);
        print('Fetch seller error: ${data['message']}'); // Debugging
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memuat profil penjual',
          'navigateToLogin': response.statusCode == 401,
        };
      }
    } catch (e) {
      print('Fetch seller exception: $e'); // Debugging
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Map<String, dynamic>> fetchReviews(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Error fetchReviews: Token tidak ditemukan');
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.get(
        Uri.parse('$baseUrl/products/$productId/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
          'fetchReviews response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        print('Error fetchReviews: Status code ${response.statusCode}');
        return {
          'success': false,
          'message': 'Gagal memuat ulasan. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error fetchReviews: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Start Chat
  Future<Map<String, dynamic>> startChat(int sellerId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No token for startChat'); // Debugging
        return {
          'success': false,
          'message': 'Silakan login terlebih dahulu',
          'navigateToLogin': true,
        };
      }
      final response = await http.post(
        Uri.parse('$baseUrl/chats/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'seller_id': sellerId}),
      );
      print('Start chat response status: ${response.statusCode}'); // Debugging
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': {
            'chat_id': data['data']['chat_id'],
            'seller_id': data['data']['seller_id'],
            'seller_name': data['data']['seller_name'],
          },
        };
      } else {
        final data = jsonDecode(response.body);
        print('Start chat error: ${data['message']}'); // Debugging
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memulai chat',
          'navigateToLogin': response.statusCode == 401,
        };
      }
    } catch (e) {
      print('Start chat exception: $e'); // Debugging
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fetch Notifications
  Future<Map<String, dynamic>> fetchNotifications({int page = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');
      bool isSeller = false;
      int? userId;

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        isSeller = userData['is_seller'] ?? false;
        userId = userData['id'] != null
            ? int.tryParse(userData['id'].toString())
            : null;
        print('User data: $userData, isSeller: $isSeller, userId: $userId');
      }

      if (token == null || userId == null) {
        return {
          'success': false,
          'message': 'Token atau user tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      print('Mengambil notifikasi dengan token: $token');
      var response = await http.get(
        Uri.parse('$baseUrl/notifications?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons: ${response.statusCode}');
      print('Isi respons: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Raw response data: ${responseData['data']}');
        List<dynamic> notifications =
            (responseData['data'] as List).map((item) {
          String time = item['created_at']?.toString() ?? '';
          if (time.isNotEmpty) {
            try {
              DateTime.parse(time);
            } catch (e) {
              print('Invalid date format for created_at: $time');
              time = DateTime.now().toIso8601String();
            }
          } else {
            time = DateTime.now().toIso8601String();
          }
          return {
            'id': item['id'] ?? 0,
            'title': item['judul']?.toString() ?? 'Tanpa Judul',
            'description': item['pesan']?.toString() ?? 'Tanpa Pesan',
            'type': item['penerima']?.toString() ?? 'unknown',
            'status': item['status']?.toString() ?? 'unknown',
            'time': time,
            'read': item['read'] ?? false,
            'chat_id': item['chat_id'],
            'seller_id': item['seller_id'],
            'user_id': item['user_id'],
          };
        }).where((item) {
          bool isRelevant = item['type'] == 'semua' ||
              item['type'] == (isSeller ? 'seller' : 'pengguna') ||
              (item['type'] == 'khusus' &&
                  ((item['seller_id'] != null &&
                          item['seller_id'] == (isSeller ? userId : null)) ||
                      (item['user_id'] != null &&
                          item['user_id'] == (isSeller ? null : userId))));
          if (!isRelevant) {
            print('Notifikasi tidak relevan: $item');
          }
          return isRelevant || (item['type'] == 'seller' && isSeller);
        }).toList();
        print('Notifikasi setelah filter: $notifications');
        return {
          'success': true,
          'data': notifications,
          'pagination': responseData['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat notifikasi. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil notifikasi: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Mark Notification as Read
  Future<Map<String, dynamic>> markNotificationAsRead(
      int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.post(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons tandai notifikasi dibaca: ${response.statusCode}');
      print('Isi respons tandai notifikasi dibaca: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Notifikasi ditandai sebagai dibaca.',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal menandai notifikasi sebagai dibaca.',
        };
      }
    } catch (e) {
      print('Kesalahan saat tandai notifikasi dibaca: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // fetchChats
  Future<Map<String, dynamic>> fetchChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.get(
        Uri.parse('$baseUrl/chats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons ambil daftar chat: ${response.statusCode}');
      print('Isi respons ambil daftar chat: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['data'] == null || responseData['data'].isEmpty) {
          return {
            'success': true,
            'data': [],
            'message': 'Tidak ada percakapan tersedia.',
          };
        }
        List<Chat> chats = (responseData['data'] as List).map((json) {
          print('Parsing chat: $json');
          String time = json['last_message_time']?.toString() ?? '';
          if (time.isNotEmpty) {
            try {
              DateTime.parse(time);
            } catch (e) {
              print('Invalid date format for last_message_time: $time');
              time = DateTime.now().toIso8601String();
            }
          } else {
            time = DateTime.now().toIso8601String();
          }
          return Chat.fromJson({
            'id': json['id'] ?? 0,
            'seller_id': json['seller_id'] ?? 0,
            'seller_name': json['seller_name'] ?? 'Penjual Tidak Diketahui',
            'last_message': json['last_message']?.isNotEmpty == true
                ? json['last_message']
                : 'Belum ada pesan',
            'last_message_time': time,
            'sender_name': json['sender_name'] ?? 'Pengguna Tidak Diketahui',
          });
        }).toList();
        return {
          'success': true,
          'data': chats,
          'message': 'Daftar chat berhasil diambil.',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat daftar chat. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil daftar chat: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

// fetchMessages
  Future<Map<String, dynamic>> fetchMessages(int chatId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No token for fetchMessages'); // Debugging
        return {
          'success': false,
          'message': 'Silakan login terlebih dahulu',
          'navigateToLogin': true,
        };
      }
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
          'Fetch messages response status: ${response.statusCode}'); // Debugging
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': (data['data'] as List)
              .map((msg) => Message.fromJson(msg))
              .toList(),
        };
      } else {
        final data = jsonDecode(response.body);
        print('Fetch messages error: ${data['message']}'); // Debugging
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memuat pesan',
          'navigateToLogin': response.statusCode == 401,
        };
      }
    } catch (e) {
      print('Fetch messages exception: $e'); // Debugging
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

// sendMessage
  Future<Map<String, dynamic>> sendMessage(int chatId, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.post(
        Uri.parse('$baseUrl/chats/$chatId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      print('Status respons kirim pesan: ${response.statusCode}');
      print('Isi respons kirim pesan: ${response.body}');

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Pesan berhasil dikirim.',
          'data': Message.fromJson(responseData['data']),
        };
      } else {
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ??
              'Gagal mengirim pesan. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat kirim pesan: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
  // ... (kode existing lainnya tetap sama)

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Silakan login terlebih dahulu',
          'navigateToLogin': true,
        };
      }

      if (data['email'] == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(data['email'])) {
        return {
          'success': false,
          'message': 'Email tidak valid.',
        };
      }

      final requestData = {
        'email': data['email'],
        'agree': true,
        'quantity': data['quantity'],
      };
      print('Mengirim data transaksi: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/process-checkout/${data['product_id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      ).timeout(Duration(seconds: 30));

      print('Status respons transaksi: ${response.statusCode}');
      print('Isi respons transaksi: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Transaksi berhasil dibuat.',
            'data': responseData['data'],
          };
        }
      } else if (response.statusCode == 400 && responseData['data'] != null && responseData['data']['snap_token'] != null) {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Transaksi tertunda ditemukan.',
          'data': responseData['data'],
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Gagal membuat transaksi.',
        'navigateToLogin': response.statusCode == 401,
      };
    } catch (e) {
      print('Kesalahan saat membuat transaksi: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<void> downloadFile(String transactionCode) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Silakan login terlebih dahulu');
      }

      print('Mengunduh file untuk transaction_code: $transactionCode');
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$transactionCode/download'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Status respons download: ${response.statusCode}');
      print('Isi respons download: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['file_url'] != null) {
          print('File URL ditemukan: ${responseData['file_url']}');
          var storagePermission = await Permission.storage.request();
          if (storagePermission.isGranted) {
            final directory = await getExternalStorageDirectory();
            if (directory == null) {
              throw Exception(
                  'Gagal mendapatkan direktori penyimpanan eksternal.');
            }
            final filePath =
                '${directory.path}/downloaded_file_${transactionCode}.pdf';
            print('Menyimpan file ke: $filePath');

            final fileResponse =
                await http.get(Uri.parse(responseData['file_url']));
            print('Status respons file download: ${fileResponse.statusCode}');
            if (fileResponse.statusCode == 200) {
              final file = File(filePath);
              await file.writeAsBytes(fileResponse.bodyBytes);
              print('File berhasil disimpan di: $filePath');
            } else {
              throw Exception(
                  'Gagal mengunduh file dari URL: Status ${fileResponse.statusCode}');
            }
          } else if (storagePermission.isPermanentlyDenied) {
            throw Exception(
                'Izin penyimpanan ditolak secara permanen. Silakan aktifkan di pengaturan.');
          } else {
            throw Exception('Izin penyimpanan ditolak.');
          }
        } else {
          throw Exception(responseData['message'] ??
              'Gagal mengunduh file: Respons server tidak valid.');
        }
      } else {
        try {
          final responseData = jsonDecode(response.body);
          throw Exception(responseData['message'] ??
              'Gagal mengunduh file: Status ${response.statusCode}');
        } catch (e) {
          throw Exception(
              'Gagal mengunduh file: Server mengembalikan respons yang tidak valid (Status ${response.statusCode}).');
        }
      }
    } catch (e) {
      print('Kesalahan saat mengunduh file: $e');
      throw Exception('Terjadi kesalahan saat mengunduh file: $e');
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await prefs.remove('token');
      await prefs.remove('user');

      if (token == null) {
        return {
          'success': true,
          'message': 'Logout berhasil.',
        };
      }

      var response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons logout: ${response.statusCode}');
      print('Isi respons logout: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Logout berhasil.',
        };
      } else {
        return {
          'success': true,
          'message': 'Logout berhasil (sesi lokal dihapus).',
        };
      }
    } catch (e) {
      print('Error during logout: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      return {
        'success': true,
        'message': 'Logout berhasil (sesi lokal dihapus).',
      };
    }
  }

  // Fetch Trending Products
  Future<Map<String, dynamic>> fetchTrendingProducts(String sortBy) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.get(
        Uri.parse('$baseUrl/trending?sort_by=$sortBy'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons ambil produk trending: ${response.statusCode}');
      print('Isi respons ambil produk trending: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] != 'success') {
          return {
            'success': false,
            'message':
                responseData['message'] ?? 'Gagal memuat produk trending.',
          };
        }

        List<Product> products = (responseData['data'] as List).map((json) {
          print('Parsing produk: $json');
          return Product.fromJson(json);
        }).toList();

        print('Jumlah produk yang berhasil diparsing: ${products.length}');
        return {
          'success': true,
          'status': 'success',
          'data': products,
          'message':
              responseData['message'] ?? 'Produk trending berhasil diambil.',
        };
      } else {
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ??
              'Gagal memuat produk trending: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil produk trending: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> fetchOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message':
              'Token tidak ditemukan atau tidak valid. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      print('Mengambil riwayat pesanan dari: $baseUrl/order-history');
      var response = await http.get(
        Uri.parse('$baseUrl/order-history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 30));

      print('Status respons ambil riwayat pesanan: ${response.statusCode}');
      print('Isi respons ambil riwayat pesanan: ${response.body}');

      if (response.statusCode == 200) {
        try {
          var responseData = jsonDecode(response.body);
          if (responseData['success'] != true) {
            return {
              'success': false,
              'message':
                  responseData['message'] ?? 'Gagal memuat riwayat pesanan.',
            };
          }

          List<dynamic> transactions =
              (responseData['data'] as List).map((json) {
            var productJson = json['product'] as Map<String, dynamic>;
            if (productJson['thumbnail'] != null &&
                !productJson['thumbnail'].startsWith('http')) {
              productJson['thumbnail'] =
                  '$storageUrl/${productJson['thumbnail']}';
            } else if (productJson['thumbnail'] == null) {
              productJson['thumbnail'] = 'https://via.placeholder.com/300x200';
            }
            return {
              'id': json['id'],
              'transaction_code': json['transaction_code'],
              'product_id': json['product_id'],
              'product': productJson,
              'amount': json['amount'] is String
                  ? double.tryParse(json['amount']) ?? 0.0
                  : (json['amount'] as num).toDouble(),
              'status': json['status'],
              'download_count': json['download_count'] ?? 0,
              'has_reviewed': json['has_reviewed'] ?? false,
            };
          }).toList();

          return {
            'success': true,
            'data': transactions,
            'message': 'Riwayat pesanan berhasil diambil.',
          };
        } catch (e) {
          print('Error parsing order history response: $e');
          return {
            'success': false,
            'message':
                'Gagal memuat riwayat pesanan: Respons server tidak valid.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat riwayat pesanan: ${response.statusCode}',
          'navigateToLogin': response.statusCode == 401,
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil riwayat pesanan: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> submitReview(
      int productId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'navigateToLogin': true,
        };
      }

      var response = await http.post(
        Uri.parse('$baseUrl/products/$productId/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': data['rating'],
          'comment': data['comment'],
        }),
      );

      print('Status respons kirim ulasan: ${response.statusCode}');
      print('Isi respons kirim ulasan: ${response.body}');

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Ulasan berhasil dikirim.',
          'data': responseData['data'],
        };
      } else {
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengirim ulasan.',
          'navigateToLogin': response.statusCode == 401,
        };
      }
    } catch (e) {
      print('Kesalahan saat kirim ulasan: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<void> cancelTransaction(String transactionCode) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Silakan login terlebih dahulu');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/transactions/$transactionCode/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        throw Exception(
            responseData['message'] ?? 'Gagal membatalkan transaksi.');
      }
    } catch (e) {
      print('Error cancelling transaction: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
