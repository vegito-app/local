import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:vegito/auth/auth_provider.dart';
import 'package:vegito/order/order_model.dart';
import 'package:vegito/order/order_provider.dart';
import 'package:vegito/order/order_screen.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart'
    show VegetableListProvider;
import 'package:vegito/vegetable/vegetable_model.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_sale_details_section.dart';

import '../mocks.mocks.dart';

void main() {
  testWidgets('OrderScreen charge les commandes et les affiche',
      (WidgetTester tester) async {
    final mockOrderProvider = MockOrderProvider();
    final mockVegetableProvider = MockVegetableListProvider();
    final mockAuthProvider = MockAuthProvider();
    final mockUser = MockUser();

    when(mockUser.uid).thenReturn('seller1');
    when(mockAuthProvider.user).thenReturn(mockUser);

    final fakeVegetables = [
      Vegetable(
        active: true,
        id: 'veg1',
        name: 'Carotte',
        description: '',
        saleType: SaleType.unit,
        priceCents: 100,
        images: [],
        createdAt: DateTime.now(),
        ownerId: 'seller1',
        availabilityType: AvailabilityType.sameDay,
        availabilityDate: null,
        quantityAvailable: 10,
      )
    ];

    final fakeOrders = [
      Order(
        id: 'order1',
        vegetableId: 'veg1',
        clientId: 'client123',
        quantity: 2,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    ];

    when(mockVegetableProvider.vegetablesByOwner('seller1'))
        .thenReturn(fakeVegetables);
    when(mockOrderProvider.loadOrdersByVegetableIds(['veg1']))
        .thenAnswer((_) async => fakeOrders);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ChangeNotifierProvider<VegetableListProvider>.value(
              value: mockVegetableProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ],
        child: const MaterialApp(home: OrderScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Carotte'), findsOneWidget);
    expect(find.textContaining('Statut'), findsOneWidget);
  });
}
