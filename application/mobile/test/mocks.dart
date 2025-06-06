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
import 'package:car2go/auth/auth_provider.dart';
import 'package:car2go/auth/auth_service.dart';
import 'package:car2go/cart/cart_provider.dart';
import 'package:car2go/order/order_provider.dart';
import 'package:car2go/order/order_service.dart';
import 'package:car2go/user/user_provider.dart';
import 'package:car2go/vegetable/vegetable_list_provider.dart';
import 'package:car2go/vegetable/vegetable_service.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:mockito/annotations.dart';
