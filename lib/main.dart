import 'package:flutter/material.dart';
import 'package:cuan_space/services/api_service.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/splash_screen.dart';
import 'screens/home.dart';
import 'screens/trending.dart';
import 'screens/profile.dart';
import 'screens/notification.dart' as NotificationScreen;
import 'screens/product_detail.dart';
import 'screens/cart.dart';
import 'screens/forgotpassword.dart';
import 'screens/resetpassword.dart';
import 'screens/sellerprofile.dart';
import 'screens/settings.dart';
import 'screens/about_us.dart';
import 'screens/help_center.dart';
import 'screens/edit_profile.dart';
import 'screens/orderconfirmation.dart';
import 'screens/checkout.dart';
import 'screens/submitreview.dart';
import 'screens/chat.dart';
import 'screens/order_history.dart';
import 'models/user_model.dart';
import 'models/user_detail_model.dart';
import 'models/product.dart';

// WARNA PALET FINAL
const darkOrange = Color(0xFFF46A24);
const pureBlack = Color(0xFF201A1A);
const softWhite = Color(0xFFFFFFFF);
const lightGrey = Color(0xFFEDEDED);
const darkGrey = Color(0xFF2A2A2A);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: darkOrange,
        scaffoldBackgroundColor: softWhite,
        colorScheme: const ColorScheme.light(
          primary: darkOrange,
          secondary: pureBlack,
          error: Colors.red,
          surface: lightGrey,
          onPrimary: softWhite,
          onSurface: pureBlack,
        ),
        textTheme: const TextTheme(
          bodyMedium:
              TextStyle(fontSize: 14, color: pureBlack, fontFamily: 'Poppins'),
          headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkOrange,
              fontFamily: 'Poppins'),
          titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: pureBlack,
              fontFamily: 'Poppins'),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkOrange,
          titleTextStyle: TextStyle(
              color: softWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins'),
          iconTheme: IconThemeData(color: softWhite),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkOrange,
            foregroundColor: softWhite,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: darkOrange, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: darkOrange, width: 2),
          ),
          labelStyle: TextStyle(color: pureBlack),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: darkOrange,
          unselectedItemColor: pureBlack,
          selectedLabelStyle:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 10),
          backgroundColor: lightGrey,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: darkOrange,
        scaffoldBackgroundColor: pureBlack,
        colorScheme: const ColorScheme.dark(
          primary: darkOrange,
          secondary: lightGrey,
          error: Colors.red,
          surface: darkGrey,
          onPrimary: softWhite,
          onSurface: softWhite,
        ),
        textTheme: const TextTheme(
          bodyMedium:
              TextStyle(fontSize: 14, color: softWhite, fontFamily: 'Poppins'),
          headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkOrange,
              fontFamily: 'Poppins'),
          titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: softWhite,
              fontFamily: 'Poppins'),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkOrange,
          titleTextStyle: TextStyle(
              color: softWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins'),
          iconTheme: IconThemeData(color: softWhite),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkOrange,
            foregroundColor: softWhite,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: darkGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: darkOrange, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: darkOrange, width: 2),
          ),
          labelStyle: TextStyle(color: softWhite),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: darkOrange,
          unselectedItemColor: softWhite,
          selectedLabelStyle:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 10),
          backgroundColor: darkGrey,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => Welcome(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/reset-password': (context) => const ResetPassword(),
        '/home': (context) => const Home(),
        '/trending': (context) => const Trending(),
        '/notification': (context) => const NotificationScreen.Notification(),
        '/profile': (context) => const Profile(),
        '/product_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return ProductDetail(
            product: args is Product
                ? args
                : Product(
                    id: 0,
                    sellerId: 0,
                    kategoriId: 0,
                    name: 'Unknown',
                    description: '',
                    price: 0.0,
                    image: '',
                    digitalFile: '',
                    status: 'unknown',
                  ),
          );
        },
        '/cart': (context) => const Cart(),
        '/checkout': (context) => const Checkout(),
        '/order-confirmation': (context) => const OrderConfirmation(),
        '/settings': (context) => const SettingsPage(),
        '/about_us': (context) =>  AboutUsPage(),
        '/help_center': (context) => HelpCenterPage(),
        '/order-history': (context) => const OrderHistory(),
        '/edit_profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return EditProfile(
            user: args is User
                ? args
                : User(
                    id: 0,
                    name: '',
                    email: '',
                    userDetail: UserDetail(
                      id: null,
                      userId: null,
                      profilePhoto: null,
                      phone: null,
                      address: null,
                      gender: null,
                      dateOfBirth: null,
                      religion: null,
                      status: null,
                    ),
                  ),
          );
        },
        '/chat': (context) => ChatScreen(),
        '/seller-profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return SellerProfileScreen(
            sellerId: args is int ? args : 0,
            sellerName: 'Nama Seller',
          );
        },
        '/submit_review': (context) => const SubmitReview(),
      },
    );
  }
}
