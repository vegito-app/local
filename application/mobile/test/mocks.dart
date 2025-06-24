import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:mockito/annotations.dart';
@GenerateMocks([
  AuthProvider,
  AuthService,
  CartProvider,
  OrderProvider,
  OrderService,
  User,
  UserProvider,
  VegetableListProvider,
  VegetableService,
])
import 'package:vegito/auth/auth_provider.dart';
import 'package:vegito/auth/auth_service.dart';
import 'package:vegito/cart/cart_provider.dart';
import 'package:vegito/order/order_provider.dart';
import 'package:vegito/order/order_service.dart';
import 'package:vegito/user/user_provider.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_service.dart';
