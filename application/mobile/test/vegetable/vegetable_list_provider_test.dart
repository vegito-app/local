import 'package:car2go/vegetable/vegetable_list_provider.dart';
import 'package:car2go/vegetable/vegetable_model.dart';
import 'package:car2go/vegetable/vegetable_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late MockVegetableService mockService;
  late VegetableListProvider provider;

  setUp(() {
    mockService = MockVegetableService();
    provider = VegetableListProvider(service: mockService);
  });

  test('reload should populate vegetables list', () async {
    final fakeVegetables = [
      Vegetable(
        id: '1',
        name: 'Carotte',
        description: 'Orange',
        saleType: 'weight',
        weightGrams: 500,
        priceCents: 150,
        images: [],
        createdAt: DateTime.now(),
        ownerId: 'user1',
      ),
    ];

    when(mockService.listVegetables()).thenAnswer((_) async => fakeVegetables);

    await provider.reload();

    expect(provider.vegetables.length, 1);
    expect(provider.vegetables.first.name, 'Carotte');
  });

  test('findByIds should return matching vegetables', () async {
    final fakeVegetables = [
      Vegetable(
        id: '1',
        name: 'Tomate',
        description: '',
        saleType: 'unit',
        weightGrams: 0,
        priceCents: 200,
        images: [],
        createdAt: DateTime.now(),
        ownerId: 'user2',
      ),
      Vegetable(
        id: '2',
        name: 'Salade',
        description: '',
        saleType: 'unit',
        weightGrams: 0,
        priceCents: 100,
        images: [],
        createdAt: DateTime.now(),
        ownerId: 'user3',
      ),
    ];

    when(mockService.listVegetables()).thenAnswer((_) async => fakeVegetables);

    final result = await provider.findByIds(['2']);

    expect(result.length, 1);
    expect(result.first.name, 'Salade');
  });
}
