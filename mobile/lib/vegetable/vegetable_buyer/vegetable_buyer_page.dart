import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vegito/config.dart';

import '../../cart/cart_screen.dart';
import '../../delivery/delivery_address_modal.dart';
import '../vegetable_card_list_tab.dart';
import '../vegetable_service.dart';
import 'buyer_filter.dart';
import 'buyer_map_tab.dart';
import 'buyer_view_model.dart';

const backendUrl = Config.backendUrl;

class VegetableBuyerPage extends StatefulWidget {
  const VegetableBuyerPage({super.key});

  @override
  State<VegetableBuyerPage> createState() => _VegetableBuyerPageState();
}

class _VegetableBuyerPageState extends State<VegetableBuyerPage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isLocating = false;

  String? _deliveryAddress;
  double? _deliveryLat;
  double? _deliveryLon;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _locateUser(BuyerViewModel viewModel) async {
    setState(() {
      _isLocating = true;
    });
    try {
      final position = await Geolocator.getCurrentPosition();
      viewModel.updateFilter(BuyerFilter(
        searchText: _searchController.text,
        userLocation: LatLng(position.latitude, position.longitude),
        onlyDeliverable: true,
      ));
      setState(() {
        _deliveryAddress = "Position actuelle";
        _deliveryLat = position.latitude;
        _deliveryLon = position.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position localisée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur localisation : $e')),
      );
    } finally {
      setState(() {
        _isLocating = false;
      });
    }
  }

  void _openDeliveryAddressModal(BuyerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (_) => DeliveryAddressModal(
        initialAddress: _deliveryAddress,
        onAddressSelected: (address, lat, lon) {
          setState(() {
            _deliveryAddress = address;
            _deliveryLat = lat;
            _deliveryLon = lon;
          });
          viewModel.updateFilter(BuyerFilter(
            searchText: _searchController.text,
            userLocation: LatLng(lat, lon),
            onlyDeliverable: true,
          ));
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final allVegetables = context.watch<VegetableListProvider>().vegetables;

    return ChangeNotifierProvider(
      create: (_) => BuyerViewModel(vegetableService: VegetableService()),
      child: Consumer<BuyerViewModel>(
        builder: (context, viewModel, _) {
          final List<Widget> tabs = [
            VegetableCardListTab(vegetables: viewModel.vegetables),
            BuyerMapTab(vegetables: viewModel.vegetables),
          ];

          return Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un légume...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (text) {
                  viewModel.updateFilter(BuyerFilter(
                    searchText: text,
                    userLocation: viewModel.currentFilter.userLocation,
                    onlyDeliverable: true,
                  ));
                },
              ),
              actions: [
                IconButton(
                  icon: _isLocating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.my_location),
                  onPressed: _isLocating
                      ? null
                      : () {
                          _locateUser(viewModel);
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.location_on),
                  tooltip: 'Modifier adresse de livraison',
                  onPressed: () => _openDeliveryAddressModal(viewModel),
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const CartScreen(),
                      ),
                    );
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: _deliveryAddress != null
                    ? Container(
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Adresse de livraison : $_deliveryAddress',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
              ),
            ),
            body: tabs[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Catalogue',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Carte',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              onTap: _onItemTapped,
            ),
          );
        },
      ),
    );
  }
}
