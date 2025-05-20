import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/theme_provider.dart';
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
import 'screens/settings.dart';
import 'screens/about_us.dart';
import 'screens/help_center.dart';
import 'screens/edit_profile.dart';
import 'models/user_model.dart';
import 'models/product.dart';

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
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.light(
          primary: Colors.orange,
          secondary: Colors.grey,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Poppins'),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.dark(
          primary: Colors.deepOrange,
          secondary: Colors.grey,
          surface: Colors.grey[900]!,
          onSurface: Colors.white,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white,fontFamily: 'Poppins'),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        scaffoldBackgroundColor: Colors.grey[900],
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
      },
    );
  }
}