import 'package:car2go/auth/auth_provider.dart';
import 'package:car2go/cart/cart_provider.dart';
import 'package:car2go/config/routes.dart';
import 'package:car2go/firebase_service.dart';
import 'package:car2go/order/consumer_order_screen.dart';
import 'package:car2go/order/order_provider.dart';
import 'package:car2go/order/order_screen.dart';
import 'package:car2go/user/user_provider.dart';
import 'package:car2go/vegetable/vegetable_list_provider.dart';
import 'package:car2go/vegetable/vegetable_seller/vegetable_seller_entry_screen.dart';
import 'package:car2go/vegetable/vegetable_seller/vegetable_seller_gallery_screen.dart';
import 'package:car2go/vegetable/vegetable_upload/vegetable_upload_provider.dart';
import 'package:car2go/vegetable/vegetable_upload/vegetable_upload_screen.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'account/account_page.dart';
import 'auth/auth_guard.dart';
import 'home_page/home_page.dart';
import 'wallet/wallet_provider.dart';
import 'wallet/wallet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  await initNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VegetableListProvider()),
        ChangeNotifierProvider(create: (_) => VegetableUploadProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        // Ajoute ici tous tes autres providers si besoin
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        FirebaseUILocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      title: 'Wallet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGuard(
        child: HomePage(),
      ),
      routes: {
        AppRoutes.wallet: (context) => const AuthGuard(child: WalletScreen()),
        // AppRoutes.home: (context) => const AuthGuard(child: HomePage()),
        AppRoutes.vegetableSellerEntry: (context) =>
            const AuthGuard(child: VegetableSellerEntryScreen()),
        AppRoutes.vegetableUpload: (context) =>
            const AuthGuard(child: VegetableUploadScreen()),
        AppRoutes.vegetableSellerGallery: (context) =>
            const AuthGuard(child: VegetableSellerGalleryScreen()),
        AppRoutes.account: (context) => const AuthGuard(child: AccountPage()),
        AppRoutes.planteurGallery: (context) =>
            const AuthGuard(child: VegetableSellerGalleryScreen()),
        AppRoutes.planteurOrders: (context) =>
            const AuthGuard(child: OrderScreen()),
        AppRoutes.clientOrders: (context) =>
            const AuthGuard(child: ConsumerOrderScreen()),
      },
    );
  }
}
