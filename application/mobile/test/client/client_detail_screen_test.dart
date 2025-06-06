import 'package:car2go/client/client_detail_screen.dart';
import 'package:car2go/client/client_detail_screen.dart';
import 'package:car2go/client/client_location_model.dart';
import 'package:car2go/client/client_location_model.dart';
import 'package:car2go/order/order_model.dart';
import 'package:car2go/order/order_provider.dart';
import 'package:car2go/user/user_model.dart';
import 'package:car2go/vegetable/vegetable_list_provider.dart';
import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

void main() {
  testWidgets('ClientDetailScreen affiche les commandes',
      (WidgetTester tester) async {
    final mockOrderProvider = MockOrderProvider();
    final mockVegetableProvider = MockVegetableListProvider();

    final client = UserProfile(
      id: 'client123',
      displayName: 'Jean Dupont',
      email: 'jean@example.com',
      location: "const Location(lat: 48.85, lng: 2.35)",
    );

    final fakeOrders = [
      Order(
        id: 'order1',
        vegetableId: 'veg1',
        clientId: 'client123',
        quantity: 3,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    ];

    final fakeVegetables = [
      Vegetable(
        id: 'veg1',
        name: 'Carotte',
        description: '',
        saleType: 'unit',
        weightGrams: 0,
        priceCents: 100,
        images: [],
        createdAt: DateTime.now(),
        ownerId: 'anyone',
      )
    ];

    when(mockOrderProvider.loadOrdersForUser('client123'))
        .thenAnswer((_) async {
      mockOrderProvider.orders.clear();
      mockOrderProvider.orders.addAll(fakeOrders);
    });
    when(mockOrderProvider.orders).thenReturn(fakeOrders);

    when(mockVegetableProvider.vegetables).thenReturn(fakeVegetables);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ChangeNotifierProvider<VegetableListProvider>.value(
              value: mockVegetableProvider),
        ],
        child: MaterialApp(
          home: ClientDetailScreen(
              client: ClientLocation(
                  id: 'client123',
                  displayName: 'Jean Dupont',
                  lat: 48.85,
                  lng: 2.35)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Jean Dupont'), findsOneWidget);
    expect(find.textContaining('Statut'), findsOneWidget);
    expect(find.textContaining('x3'), findsOneWidget);
    expect(find.textContaining('Carotte'), findsOneWidget);
  });
}
