import 'package:car2go/auth/auth_provider.dart';
import 'package:car2go/cart/cart_provider.dart';
import 'package:car2go/cart/cart_validate_order.dart';
import 'package:car2go/order/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

void main() {
  testWidgets('validateOrders envoie les commandes et vide le panier',
      (tester) async {
    final mockAuth = MockAuthProvider();
    final mockCart = MockCartProvider();
    final mockOrder = MockOrderProvider();
    final mockUser = MockUser();

    when(mockUser.uid).thenReturn('user123');
    when(mockAuth.user).thenReturn(mockUser);
    when(mockCart.items).thenReturn(Map.from({'veg1': 2}));
    when(mockOrder.validateCartOrders(any, any)).thenAnswer((_) async => {});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
          ChangeNotifierProvider<CartProvider>.value(value: mockCart),
          ChangeNotifierProvider<OrderProvider>.value(value: mockOrder),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                validateOrders(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    verify(mockOrder.validateCartOrders('user123', {'veg1': 2})).called(1);
    verify(mockCart.clear()).called(1);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
