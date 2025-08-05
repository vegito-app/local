class ClientLocation {
  final String id;
  final String displayName;
  final double lat;
  final double lng;
  final String? address;

  ClientLocation({
    required this.id,
    required this.displayName,
    required this.lat,
    required this.lng,
    this.address,
  });

  factory ClientLocation.fromMap(String id, Map<String, dynamic> data) {
    final location = data['location'];
    if (location is Map<String, dynamic>) {
      return ClientLocation(
        id: id,
        displayName: data['displayName'] as String,
        lat: location['lat'] as double,
        lng: location['lng'] as double,
        address: data['address'] as String,
      );
    }
    throw Exception("Invalid or missing location for user $id");
  }
}
