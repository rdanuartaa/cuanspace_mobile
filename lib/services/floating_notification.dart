import 'package:flutter/material.dart';

class FloatingNotification extends StatefulWidget {
  final String message;
  final Duration duration;

  FloatingNotification({
    required this.message,
    this.duration = const Duration(seconds: 3),
  });

  @override
  _FloatingNotificationState createState() => _FloatingNotificationState();
}

class _FloatingNotificationState extends State<FloatingNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Tampilkan notifikasi
    _controller.forward();

    // Sembunyikan setelah durasi tertentu
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          _overlayEntry.remove();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _animation,
        child: Material(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              widget.message,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

void showFloatingNotification(BuildContext context, String message) {
  final overlayState = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => FloatingNotification(message: message),
  );
  overlayState.insert(overlayEntry);
}