import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  // Instance de FirebaseAuth.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Container(
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('chemin/vers/votre/image.png'),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          Center(
            child: ElevatedButton(
              onPressed: _signInAnonymously,
              child: const Text('Se connecter'),
            ),
          ),
        ],
      ),
    );
  }

//   Future<void> _signInAnonymously() async {
//     final userCredential = await FirebaseAuth.instance.signInAnonymously();
//     print('${userCredential.user?.uid}');
//   }
// }

  Future<void> _signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      print('Connecté avec succès : ${userCredential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed') {
        print('Connexion anonyme non activée');
      } else {
        print(e.message);
      }
    }
  }
}
