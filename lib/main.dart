import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cuan_space/services/theme_provider.dart';
import 'package:cuan_space/services/api_service.dart';
import 'package:cuan_space/bloc/trending/trending_bloc.dart';
import 'package:cuan_space/bloc/trending/trending_event.dart';
import 'package:cuan_space/screens/chat.dart';
import 'package:cuan_space/screens/welcome.dart';
import 'package:cuan_space/screens/login.dart';
import 'package:cuan_space/screens/register.dart';
import 'package:cuan_space/screens/splash_screen.dart';
import 'package:cuan_space/screens/home.dart';
import 'package:cuan_space/screens/explore.dart';
import 'package:cuan_space/screens/profile.dart';
import 'package:cuan_space/screens/notification.dart' as NotificationScreen;
import 'package:cuan_space/screens/product_detail.dart';
import 'package:cuan_space/screens/cart.dart';
import 'package:cuan_space/screens/forgotpassword.dart';
import 'package:cuan_space/screens/resetpassword.dart';
import 'package:cuan_space/screens/sellerprofile.dart';
import 'package:cuan_space/screens/settings.dart';
import 'package:cuan_space/screens/about_us.dart';
import 'package:cuan_space/screens/help_center.dart';
import 'package:cuan_space/screens/edit_profile.dart';
import 'package:cuan_space/models/user_model.dart';
import 'package:cuan_space/models/user_detail_model.dart';
import 'package:cuan_space/models/product.dart';

// WARNA PALET FINAL
const darkOrange = Color(0xFFF46A24);
const pureBlack = Color(0xFF201A1A);
const softWhite = Color(0xFFFFFFFF);
const lightGrey = Color(0xFFEDEDED);
const darkGrey = Color(0xFF2A2A2A);

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: BlocProvider(
        create: (context) => TrendingBloc(ApiService())
          ..add(const FetchTrendingProducts('views')),
        child: const MyApp(),
      ),
    ),
  );
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
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      initialRoute: '/welcome',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => Welcome(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/home': (context) => Home(),
        '/explore': (context) => Explore(),
        '/notification': (context) => NotificationScreen.Notification(),
        '/profile': (context) => Profile(),
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
                    purchaseCount: 0,
                  ),
          );
        },
        '/cart': (context) => Cart(),
        '/forgot-password': (context) => ForgotPassword(),
        '/reset-password': (context) => ResetPassword(),
        '/settings': (context) => SettingsPage(),
        '/about_us': (context) => AboutUsPage(),
        '/help_center': (context) => HelpCenterPage(),
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
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const Explore(),
    NotificationScreen.Notification(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Beranda', // Diubah dari 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, size: 24),
            label: 'Jelajah', // Diubah dari 'Explore'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 24),
            label: 'Notifikasi', // Diubah dari 'Notifications'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Profil', // Diubah dari 'Profile'
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: darkOrange,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
        showUnselectedLabels: true,
      ),
    );
  }
}
