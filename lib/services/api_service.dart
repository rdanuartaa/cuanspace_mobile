import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kategori.dart';
import '../models/product.dart';
import '../models/user_model.dart';

class ApiService {
static const String baseUrl = 'http://127.0.0.1:8000/api'; // Sesuaikan dengan web Anda
  //static const String baseUrl = 'http://10.0.2.2/api'; // Sesuaikan dengan emulator Anda
  //  static const String baseUrl = 'http://192.168.189.55:8000/api'; 
  // static const String storageUrl = 'http://192.168.189.55:8000/storage'; // Storage endpoint
static const String storageUrl = 'http://127.0.0.1:8000/storage'; 
  // Fungsi untuk login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['data']['token']);
          await prefs.setString('user', jsonEncode(responseData['data']['user']));
          return {
            'success': true,
            'message': 'Login berhasil',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Login gagal.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Kesalahan server: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error during login: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk register
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
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

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return {
            'success': true,
            'message': 'Registrasi berhasil',
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
      print('Error during register: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/password/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      print('Forgot password response status: ${response.statusCode}');
      print('Forgot password response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Permintaan reset password telah dikirim.',
        };
      } else {
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['email']?[0] ?? 'Gagal mengirim permintaan.',
        };
      }
    } catch (e) {
      print('Error during forgot password: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk reset password
  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String password, String passwordConfirmation) async {
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

      print('Reset password response status: ${response.statusCode}');
      print('Reset password response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password berhasil direset.',
        };
      } else {
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['email']?[0] ?? 'Gagal mereset password.',
        };
      }
    } catch (e) {
      print('Error during reset password: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk fetch data home
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

      print('Fetch home data response status: ${response.statusCode}');
      print('Fetch home data response body: ${response.body}');

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
      print('Error during fetch home data: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk fetch data kategori
  Future<Map<String, dynamic>> fetchKategoris() async {
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
      Uri.parse('$baseUrl/kategoris'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Fetch kategoris response status: ${response.statusCode}');
    print('Fetch kategoris response body: ${response.body}');

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      List<Kategori> kategoris = (responseData['data'] as List)
          .map((json) => Kategori.fromJson(json))
          .toList();
      return {
        'success': true,
        'data': kategoris,
      };
    } else {
      return {
        'success': false,
        'message': 'Gagal memuat kategori.',
      };
    }
  } catch (e) {
    print('Error during fetch kategoris: $e');
    return {
      'success': false,
      'message': 'Terjadi kesalahan: $e',
    };
  }
}

  // Fungsi untuk fetch data produk
Future<Map<String, dynamic>> fetchProducts() async {
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
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Fetch products response status: ${response.statusCode}');
    print('Fetch products response body: ${response.body}');

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      List<Product> products = (responseData['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
      return {
        'success': true,
        'data': products,
      };
    } else {
      return {
        'success': false,
        'message': 'Gagal memuat produk.',
      };
    }
  } catch (e) {
    print('Error during fetch products: $e');
    return {
      'success': false,
      'message': 'Terjadi kesalahan: $e',
    };
  }
}

  // Fungsi untuk fetch data profil
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

      print('Fetch user profile response status: ${response.statusCode}');
      print('Fetch user profile response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': User.fromMap(responseData),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat data profil.',
        };
      }
    } catch (e) {
      print('Error during fetch user profile: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk update profil dan upload foto
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

      // Tambahkan header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Tambahkan field teks
      if (name != null) request.fields['name'] = name;
      if (email != null) request.fields['email'] = email;
      if (phone != null) request.fields['phone'] = phone;
      if (address != null) request.fields['address'] = address;
      if (gender != null) request.fields['gender'] = gender;
      if (dateOfBirth != null) request.fields['date_of_birth'] = dateOfBirth;
      if (religion != null) request.fields['religion'] = religion;
      if (status != null) request.fields['status'] = status;

      // Tambahkan file foto profil jika ada
      if (profilePhotoPath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_photo',
          profilePhotoPath,
        ));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Update profile response status: ${response.statusCode}');
      print('Update profile response body: $responseBody');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(responseBody);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profil berhasil diperbarui',
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
      print('Error during update profile: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk mengambil daftar notifikasi
  Future<Map<String, dynamic>> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali',
          'navigateToLogin': true,
        };
      }

      var response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status respons ambil notifikasi: ${response.statusCode}');
      print('Isi respons ambil notifikasi: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat notifikasi',
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

  // Fungsi untuk logout  
  Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Selalu hapus token dan data pengguna dari SharedPreferences
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

      print('Logout response status: ${response.statusCode}');
      print('Logout response body: ${response.body}');

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
}