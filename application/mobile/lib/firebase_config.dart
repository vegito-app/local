import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

final client = http.Client();

class FirebaseConfigService {
  Future<FirebaseOptions> getConfig(String configEndpointPath) async {
    final response = await client.get(Uri.parse(configEndpointPath));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return FirebaseOptions(
        apiKey: data['apiKey'].toString(),
        appId: data['appId'].toString(),
        messagingSenderId: data['messagingSenderId'].toString(),
        projectId: data['projectId'].toString(),
      );
    } else {
      throw Exception('Failed to load config');
    }
  }
}
