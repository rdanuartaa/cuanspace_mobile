import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/theme_provider.dart';
import 'screens/chat.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/splash_screen.dart' as SplashScreen;
import 'screens/home.dart';
import 'screens/explore.dart';
import 'screens/profile.dart';
import 'screens/notification.dart' as Notification;
import 'screens/product_detail.dart';
import 'screens/cart.dart';
import 'screens/forgotpassword.dart';
import 'screens/resetpassword.dart';
import 'screens/sellerprofile.dart';
import 'screens/settings.dart';
import 'screens/about_us.dart';
import 'screens/help_center.dart';
import 'screens/edit_profile.dart';
import 'models/user_model.dart';
import 'models/product.dart';

// WARNA PALET FINAL
const darkOrange = Color(0xFFF46A24);   // Orange gelap
const pureBlack = Color(0xFF201A1A);    // Hitam solid
const softWhite = Color(0xFFFFFFFF);    // Putih
const lightGrey = Color(0xFFEDEDED);    // Abu terang untuk tema terang
const darkGrey = Color(0xFF2A2A2A);     // Abu gelap untuk tema gelap

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: darkOrange,
        scaffoldBackgroundColor: softWhite,
        colorScheme: ColorScheme.light(
          primary: darkOrange,
          secondary: pureBlack,
          error: Colors.red[700]!,
          background: lightGrey,
          onPrimary: softWhite,
          surface: lightGrey,
          onSurface: pureBlack,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 14, color: pureBlack, fontFamily: 'Poppins'),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkOrange, fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pureBlack, fontFamily: 'Poppins'),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkOrange,
          titleTextStyle: TextStyle(color: softWhite, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          iconTheme: IconThemeData(color: softWhite),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkOrange,
            foregroundColor: softWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkOrange, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkOrange, width: 2),
          ),
          labelStyle: TextStyle(color: pureBlack),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: darkOrange,
          unselectedItemColor: pureBlack,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 10),
          backgroundColor: lightGrey,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: darkOrange,
        scaffoldBackgroundColor: pureBlack,
        colorScheme: ColorScheme.dark(
          primary: darkOrange,
          secondary: lightGrey,
          error: Colors.red[700]!,
          background: darkGrey,
          onPrimary: softWhite,
          surface: darkGrey,
          onSurface: softWhite,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 14, color: softWhite, fontFamily: 'Poppins'),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkOrange, fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: softWhite, fontFamily: 'Poppins'),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkOrange,
          titleTextStyle: TextStyle(color: softWhite, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          iconTheme: IconThemeData(color: softWhite),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkOrange,
            foregroundColor: softWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkOrange, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkOrange, width: 2),
          ),
          labelStyle: TextStyle(color: softWhite),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: darkOrange,
          unselectedItemColor: softWhite,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 10),
          backgroundColor: darkGrey,
        ),
      ),
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => Welcome(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/splash': (context) => SplashScreen.SplashScreen(),
        '/home': (context) => Home(),
        '/explore': (context) => Explore(),
        '/profile': (context) => Profile(),
        '/notification': (context) => Notification.Notification(),
        '/product_detail': (context) => ProductDetail(
              product: ModalRoute.of(context)!.settings.arguments as Product,
            ),
        '/cart': (context) => Cart(),
        '/forgot-password': (context) => ForgotPassword(),
        '/reset-password': (context) => ResetPassword(),
        '/settings': (context) => SettingsPage(),
        '/about_us': (context) => AboutUsPage(),
        '/help_center': (context) => HelpCenterPage(),
        '/edit_profile': (context) => EditProfile(
              user: ModalRoute.of(context)!.settings.arguments as User,
            ),
        '/chat': (context) => ChatScreen(),
        '/seller-profile': (context) => SellerProfileScreen(
              sellerId: ModalRoute.of(context)!.settings.arguments as int,
              sellerName: 'Nama Seller',
            ),
      },
    );
  }
}