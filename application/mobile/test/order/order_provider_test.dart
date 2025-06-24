import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vegito/order/order_provider.dart' show OrderProvider, User;

import '../mocks.mocks.dart';

void main() {
  late OrderProvider provider;
  late MockOrderService mockService;

  setUp(() {
    mockService = MockOrderService();
    provider = OrderProvider(service: mockService);
  });

  test('validateCartOrders appelle createOrder pour chaque item du panier',
      () async {
    final cartItems = {'veg1': 2, 'veg2': 1};

    when(mockService.createOrder(
      vegetableId: anyNamed('vegetableId'),
      clientId: anyNamed('clientId'),
      quantity: anyNamed('quantity'),
    )).thenAnswer((_) async => {});

    await provider.validateCartOrders('user123', cartItems);

    verify(mockService.createOrder(
      vegetableId: 'veg1',
      clientId: 'user123',
      quantity: 2,
    )).called(1);

    verify(mockService.createOrder(
      vegetableId: 'veg2',
      clientId: 'user123',
      quantity: 1,
    )).called(1);
  });
}
