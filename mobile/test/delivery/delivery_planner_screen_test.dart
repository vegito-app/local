import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:vegito/delivery/delivery_planner_screen.dart';
import 'package:vegito/order/order_model.dart';
import 'package:vegito/order/order_provider.dart';
import 'package:vegito/user/user_model.dart';
import 'package:vegito/user/user_provider.dart';
import 'package:vegito/vegetable/vegetable_list_provider.dart';
import 'package:vegito/vegetable/vegetable_model.dart';
import 'package:vegito/vegetable/vegetable_upload/vegetable_sale_details_section.dart';

import '../mocks.mocks.dart';

void main() {
  testWidgets('DeliveryPlannerScreen builds and shows UI elements',
      (WidgetTester tester) async {
    final mockVegProvider = MockVegetableListProvider();
    final mockOrderProvider = MockOrderProvider();
    final mockUserProvider = MockUserProvider();

    final fakeUser = UserProfile(
      anonymous: true,
      id: 'seller1',
      displayName: 'Seller One',
      email: 'seller1@example.com',
    );

    final fakeVegetables = [
      Vegetable(
        active: true,
        id: 'veg1',
        name: 'Tomate',
        description: '',
        saleType: SaleType.unit,
        priceCents: 100,
        images: [],
        createdAt: DateTime.now(),
        ownerId: 'seller1',
        availabilityType: AvailabilityType.sameDay,
        availabilityDate: null,
        quantityAvailable: 10,
      ),
    ];

    final fakeOrders = [
      Order(
        id: 'order1',
        vegetableId: 'veg1',
        clientId: 'client1',
        quantity: 5,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    ];

    when(mockUserProvider.getCurrentUser('client1')).thenReturn(
      UserProfile(
        anonymous: false,
        id: 'client1',
        displayName: 'Client One',
        email: 'client1@example.com',
        location: null,
      ),
    );

    when(mockUserProvider.getCurrentUser('seller1')).thenReturn(fakeUser);
    when(mockVegProvider.vegetables).thenReturn(fakeVegetables);
    when(mockOrderProvider.loadOrdersByVegetableIds(['veg1']))
        .thenAnswer((_) async => fakeOrders);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<VegetableListProvider>.value(
              value: mockVegProvider),
          ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ],
        child: const MaterialApp(
          home: DeliveryPlannerScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Prévision de livraison'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.text('Cartographier les clients'), findsOneWidget);
  });
}
