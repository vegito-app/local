import 'package:flutter/material.dart';
import '../activity_screen.dart';

class AccountActivityButton extends StatelessWidget {
  const AccountActivityButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.timeline),
      label: const Text("Mon activité"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<Widget>(
            builder: (context) => const ActivityScreen(),
          ),
        );
      },
    );
  }
}
