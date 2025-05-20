import 'package:flutter/material.dart';
import '../services/api_service.dart';


class Register extends StatefulWidget {
    @override
    _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SingleTickerProviderStateMixin {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late Animation<double> _buttonAnimation;
    final ApiService _apiService = ApiService(); // Inisialisasi ApiService

    @override
    void initState() {
        super.initState();
        _animationController = AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
        );

        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
        );

        _buttonAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );

        _animationController.forward();
    }

    @override
    void dispose() {
        _nameController.dispose();
        _emailController.dispose();
        _passwordController.dispose();
        _confirmPasswordController.dispose();
        _animationController.dispose();
        super.dispose();
    }

    Future<void> registerUser() async {
        if (_formKey.currentState!.validate()) {
          var result = await _apiService.register(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
          );

          if (result['success']) {
            Navigator.pushNamed(context, '/login');
          } else {
            _showErrorDialog(result['message']);
          }
        }
    }

    void _showErrorDialog(String message) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text('Error', style: TextStyle(fontFamily: 'Poppins')),
                content: Text(message, style: TextStyle(fontFamily: 'Poppins')),
                actions: [
                  TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK', style: TextStyle(fontFamily: 'Poppins', color: Colors.orange)),
                    ),
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFFF8BBD0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                    ),
                ),
                child: SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minHeight: MediaQuery.of(context).size.height -
                                            MediaQuery.of(context).padding.top -
                                            MediaQuery.of(context).padding.bottom,
                                    ),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            SizedBox(height: 20),
                                            FadeTransition(
                                                opacity: _fadeAnimation,
                                                child: Image.asset(
                                                    'assets/images/Logo.png',
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.contain,
                                                ),
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                                'Add your details to sign up',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16,
                                                    color: Colors.white70,
                                                ),
                                            ),
                                            SizedBox(height: 30),
                                            Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.9),
                                                    borderRadius: BorderRadius.circular(15),
                                                    boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black.withOpacity(0.2),
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                            offset: Offset(0, 3),
                                                        ),
                                                    ],
                                                ),
                                                child: TextFormField(
                                                    controller: _nameController,
                                                    decoration: InputDecoration(
                                                        labelText: 'Name',
                                                        labelStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                                                        border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(15),
                                                            borderSide: BorderSide.none,
                                                        ),
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                        prefixIcon: Icon(Icons.person, color: Colors.orange),
                                                    ),
                                                    style: TextStyle(fontFamily: 'Poppins'),
                                                    validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                            return 'Masukkan nama Anda';
                                                        }
                                                        return null;
                                                    },
                                                ),
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.9),
                                                    borderRadius: BorderRadius.circular(15),
                                                    boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black.withOpacity(0.2),
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                            offset: Offset(0, 3),
                                                        ),
                                                    ],
                                                ),
                                                child: TextFormField(
                                                    controller: _emailController,
                                                    keyboardType: TextInputType.emailAddress,
                                                    decoration: InputDecoration(
                                                        labelText: 'Email',
                                                        labelStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                                                        border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(15),
                                                            borderSide: BorderSide.none,
                                                        ),
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                        prefixIcon: Icon(Icons.email, color: Colors.orange),
                                                    ),
                                                    style: TextStyle(fontFamily: 'Poppins'),
                                                    validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                            return 'Masukkan email Anda';
                                                        }
                                                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                                            return 'Masukkan email yang valid';
                                                        }
                                                        return null;
                                                    },
                                                ),
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.9),
                                                    borderRadius: BorderRadius.circular(15),
                                                    boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black.withOpacity(0.2),
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                            offset: Offset(0, 3),
                                                        ),
                                                    ],
                                                ),
                                                child: TextFormField(
                                                    controller: _passwordController,
                                                    obscureText: true,
                                                    decoration: InputDecoration(
                                                        labelText: 'Password',
                                                        labelStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                                                        border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(15),
                                                            borderSide: BorderSide.none,
                                                        ),
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                        prefixIcon: Icon(Icons.lock, color: Colors.orange),
                                                    ),
                                                    style: TextStyle(fontFamily: 'Poppins'),
                                                    validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                            return 'Masukkan kata sandi Anda';
                                                        }
                                                        if (value.length < 8) {
                                                            return 'Kata sandi minimal 8 karakter';
                                                        }
                                                        return null;
                                                    },
                                                ),
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.9),
                                                    borderRadius: BorderRadius.circular(15),
                                                    boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black.withOpacity(0.2),
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                            offset: Offset(0, 3),
                                                        ),
                                                    ],
                                                ),
                                                child: TextFormField(
                                                    controller: _confirmPasswordController,
                                                    obscureText: true,
                                                    decoration: InputDecoration(
                                                        labelText: 'Confirm Password',
                                                        labelStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                                                        border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(15),
                                                            borderSide: BorderSide.none,
                                                        ),
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                        prefixIcon: Icon(Icons.lock, color: Colors.orange),
                                                    ),
                                                    style: TextStyle(fontFamily: 'Poppins'),
                                                    validator: (value) {
                                                        if (value == null || value.isEmpty) {
                                                            return 'Masukkan konfirmasi kata sandi';
                                                        }
                                                        if (value != _passwordController.text) {
                                                            return 'Kata sandi tidak cocok';
                                                        }
                                                        return null;
                                                    },
                                                ),
                                            ),
                                            SizedBox(height: 20),
                                            MouseRegion(
                                                onEnter: (_) => _animationController.forward(),
                                                onExit: (_) => _animationController.reverse(),
                                                child: ScaleTransition(
                                                    scale: _buttonAnimation,
                                                    child: Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                                colors: [Colors.orange, Colors.deepOrange],
                                                                begin: Alignment.topLeft,
                                                                end: Alignment.bottomRight,
                                                            ),
                                                            borderRadius: BorderRadius.circular(30),
                                                            boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors.orange.withOpacity(0.4),
                                                                    spreadRadius: 2,
                                                                    blurRadius: 8,
                                                                    offset: Offset(0, 4),
                                                                ),
                                                            ],
                                                        ),
                                                        child: ElevatedButton(
                                                            onPressed: registerUser,
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.transparent,
                                                                shadowColor: Colors.transparent,
                                                                padding: EdgeInsets.symmetric(vertical: 16),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(30),
                                                                ),
                                                            ),
                                                            child: Text(
                                                                'Sign Up',
                                                                style: TextStyle(
                                                                    fontFamily: 'Poppins',
                                                                    fontSize: 18,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            SizedBox(height: 20),
                                            Center(
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                        Text(
                                                            'Already have an Account? ',
                                                            style: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
                                                        ),
                                                        TextButton(
                                                            onPressed: () => Navigator.pushNamed(context, '/login'),
                                                            child: Text(
                                                                'Login',
                                                                style: TextStyle(
                                                                    fontFamily: 'Poppins',
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            SizedBox(height: 20), // Tambahan padding bawah
                                        ],
                                    ),
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}