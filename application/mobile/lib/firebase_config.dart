import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';

final client = http.Client();

class FirebaseConfigService {
  Future<FirebaseOptions> getConfig(String configEndpointPath) async {
    final response = await client.get(Uri.parse(configEndpointPath));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return FirebaseOptions(
        apiKey: data['apiKey'],
        appId: data['appId'],
        messagingSenderId: data['messagingSenderId'],
        projectId: data['projectId'],
      );
    } else {
      throw Exception('Failed to load config');
    }
  }
}
