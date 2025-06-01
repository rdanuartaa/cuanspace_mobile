import 'package:flutter/material.dart';
import 'package:cuan_space/services/api_service.dart';
import '/main.dart';

class SubmitReview extends StatefulWidget {
  const SubmitReview({super.key});

  @override
  _SubmitReviewState createState() => _SubmitReviewState();
}

class _SubmitReviewState extends State<SubmitReview> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  double rating = 1.0;
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = false;

  void showFloatingNotification(String message) {
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> submitReview(Map<String, dynamic> args) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await apiService.submitReview(args['product_id'], {
        'rating': rating.toInt(),
        'comment': _commentController.text,
      });

      setState(() {
        isLoading = false;
      });

      if (result['success']) {
        showFloatingNotification('Ulasan berhasil dikirim!');
        Navigator.pop(context);
        Navigator.pushNamed(context, '/profile');
      } else {
        showFloatingNotification(result['message']);
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showFloatingNotification('Terjadi kesalahan: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Berikan Ulasan'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ulasan untuk: ${args['product_name']}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rating',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<double>(
                value: rating,
                items: List.generate(5, (index) {
                  final value = (index + 1).toDouble();
                  return DropdownMenuItem<double>(
                    value: value,
                    child: Text('$value'),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    rating = value ?? 1.0;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Rating (1-5)',
                ),
                validator: (value) {
                  if (value == null || value < 1 || value > 5) {
                    return 'Pilih rating antara 1 hingga 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Komentar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tulis komentar Anda',
                  hintText: 'Bagaimana pengalaman Anda dengan produk ini?',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Komentar tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => submitReview(args),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkOrange,
                  foregroundColor: softWhite,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: softWhite)
                    : const Text(
                        'Kirim Ulasan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}