import 'package:http/http.dart' as http;
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
  static const String baseUrl = 'http://localhost:8000/api';
  static const String storageUrl = 'http://localhost:8000/storage';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print('Login response status: ${response.statusCode}, body: ${response.body}'); // Debugging
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['token'];
        final user = data['data']['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token); // Changed from 'auth_token' to 'token'
        await prefs.setString('user', jsonEncode(user)); // Save user data
        print('Login token saved: $token'); // Debugging
        final savedToken = await _getToken();
        print('Verified saved token: $savedToken'); // Debugging
        return {
          'success': true,
          'message': 'Login berhasil',
          'data': data['data'],
        };
      } else {
        final data = jsonDecode(response.body);
        print('Login error: ${data['message']}'); // Debugging
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      print('Login exception: $e'); // Debugging
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
      // Asumsi: API endpoint untuk mendapatkan data user
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return User.fromMap(jsonDecode(response.body)['data']);
      }
      return null;
    } catch (e) {
      print('Error getCurrentUser: $e');
      return null;
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
    final token = prefs.getString('token'); // Changed from 'auth_token' to 'token'
    print('Retrieved token: $token'); // Debugging
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

      print('Status respons ambil ulasan: ${response.statusCode}');
      print('Isi respons ambil ulasan: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat ulasan. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Kesalahan saat ambil ulasan: $e');
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

      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': data['product_id'],
          'quantity': data['quantity'],
        }),
      );

      print('Status respons transaksi: ${response.statusCode}');
      print('Isi respons transaksi: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Transaksi berhasil dibuat.',
          'data': responseData['data'],
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal membuat transaksi.',
          'navigateToLogin': response.statusCode == 401,
        };
      }
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

      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$transactionCode/download'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons download: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Placeholder: Tangani file download
        // Contoh: saveFile(response.bodyBytes, 'downloaded_file');
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal mengunduh file.');
      }
    } catch (e) {
      print('Kesalahan saat mengunduh file: $e');
      throw Exception('Terjadi kesalahan: $e');
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

      // Validate sortBy parameter to prevent injection
      final validSortOptions = [
        'popularity',
        'price',
        'newest',
        'rating',
        'views',
        'purchases'
      ];
      if (!validSortOptions.contains(sortBy)) {
        return {
          'success': false,
          'message': 'Parameter sortBy tidak valid.',
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
        if (responseData['data'] == null) {
          return {
            'success': false,
            'message': 'Data produk trending tidak ditemukan.',
          };
        }

        // Di method fetchTrendingProducts dalam ApiService
        List<Map<String, dynamic>> productsData = [];
        if (responseData['data'] is List) {
          productsData = (responseData['data'] as List).map((json) {
            // Convert LinkedMap to Map<String, dynamic> first
            final Map<String, dynamic> item = Map<String, dynamic>.from(json);

            // Handle both thumbnail and image with fallback
            final imagePath = item['thumbnail'] != null &&
                    item['thumbnail'].toString().isNotEmpty
                ? '$storageUrl/${item['thumbnail']}'
                : (item['image'] != null && item['image'].toString().isNotEmpty
                    ? '$storageUrl/${item['image']}'
                    : null);

            item['image'] = imagePath ?? '';
            return item;
          }).toList();
        }

        return {
          'success': true,
          'data': productsData, // Ini sudah List<Map<String, dynamic>>
          'message': 'Produk trending berhasil diambil.',
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
}