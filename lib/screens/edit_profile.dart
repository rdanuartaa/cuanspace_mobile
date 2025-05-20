import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart.dart';

class EditProfile extends StatefulWidget {
  final User user;

  EditProfile({required this.user});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _gender;
  DateTime? _dateOfBirth;
  String? _religion;
  String? _status;
  File? _profilePhoto;
  bool isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.userDetail?.phone);
    _addressController = TextEditingController(text: widget.user.userDetail?.address);
    _gender = widget.user.userDetail?.gender;
    _dateOfBirth = widget.user.userDetail?.dateOfBirth != null
        ? DateFormat('yyyy-MM-dd').parse(widget.user.userDetail!.dateOfBirth!)
        : null;
    _religion = widget.user.userDetail?.religion;
    _status = widget.user.userDetail?.status;
    _loadToken();
  }

  // Fungsi untuk menampilkan notifikasi melayang
  void showFloatingNotification(String message) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Hapus notifikasi setelah 3 detik
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Pangkas gambar setelah dipilih
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Pangkas Gambar',
              toolbarColor: Colors.orange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              activeControlsWidgetColor: Colors.orange,
            ),
            IOSUiSettings(
              title: 'Pangkas Gambar',
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _profilePhoto = File(croppedFile.path);
          });
          print('Gambar berhasil dipangkas: ${croppedFile.path}');
        } else {
          print('Pemangkasan gambar dibatalkan');
          showFloatingNotification('Pemangkasan gambar dibatalkan');
        }
      } else {
        print('Pemilihan gambar dibatalkan');
        showFloatingNotification('Pemilihan gambar dibatalkan');
      }
    } catch (e) {
      print('Error saat memilih atau memangkas gambar: $e');
      showFloatingNotification('Gagal memilih atau memangkas gambar: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ).copyWith(
              brightness: Theme.of(context).brightness, // Menyesuaikan brightness dengan tema aplikasi
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
            textTheme: Theme.of(context).textTheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final result = await apiService.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        gender: _gender,
        dateOfBirth: _dateOfBirth != null ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!) : null,
        religion: _religion,
        status: _status,
        profilePhotoPath: _profilePhoto?.path,
      );

      setState(() {
        isLoading = false;
      });

      if (result['success']) {
        Navigator.pop(context, result['data']);
        showFloatingNotification(result['message']);
      } else {
        showFloatingNotification(result['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 60), // Ruang untuk tombol kembali dan ikon
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: _profilePhoto != null
                                ? ClipOval(
                                    child: Image.file(
                                      _profilePhoto!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Error loading local photo: $error');
                                        return widget.user.userDetail?.profilePhoto != null &&
                                                widget.user.userDetail!.profilePhoto!.isNotEmpty
                                            ? Image.network(
                                                '${ApiService.storageUrl}/${widget.user.userDetail!.profilePhoto}',
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                                headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                                                errorBuilder: (context, error, stackTrace) {
                                                  print('Error loading network photo: $error');
                                                  return Icon(
                                                    Icons.person,
                                                    size: 70,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  );
                                                },
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 70,
                                                color: Theme.of(context).colorScheme.primary,
                                              );
                                      },
                                    ),
                                  )
                                : widget.user.userDetail?.profilePhoto != null &&
                                        widget.user.userDetail!.profilePhoto!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          '${ApiService.storageUrl}/${widget.user.userDetail!.profilePhoto}',
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                          headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Error loading network photo: $error');
                                            return Icon(
                                              Icons.person,
                                              size: 70,
                                              color: Theme.of(context).colorScheme.primary,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 70,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nama',
                                    prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Nomor Telepon',
                                    prefixIcon: Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _addressController,
                                  decoration: InputDecoration(
                                    labelText: 'Alamat',
                                    prefixIcon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _gender,
                                  decoration: InputDecoration(
                                    labelText: 'Jenis Kelamin',
                                    prefixIcon:
                                        Icon(Icons.transgender, color: Theme.of(context).colorScheme.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  dropdownColor: Theme.of(context).colorScheme.surface,
                                  items: ['Laki-laki', 'Perempuan'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _gender = value),
                                ),
                                SizedBox(height: 16),
                                InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Tanggal Lahir',
                                      prefixIcon:
                                          Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(
                                      _dateOfBirth != null
                                          ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
                                          : 'Pilih tanggal',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _religion,
                                  decoration: InputDecoration(
                                    labelText: 'Agama',
                                    prefixIcon:
                                        Icon(Icons.account_balance, color: Theme.of(context).colorScheme.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  dropdownColor: Theme.of(context).colorScheme.surface,
                                  items: ['Islam', 'Kristen', 'Hindu', 'Buddha', 'Konghucu', 'Lainnya']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _religion = value),
                                ),
                                SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _status,
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    prefixIcon: Icon(Icons.work, color: Theme.of(context).colorScheme.primary),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  dropdownColor: Theme.of(context).colorScheme.surface,
                                  items: ['Pelajar', 'Mahasiswa', 'Pekerja', 'Wirausaha', 'Lainnya'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _status = value),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Simpan Perubahan',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          // Tombol Kembali dan Ikon Keranjang
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Cart()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}