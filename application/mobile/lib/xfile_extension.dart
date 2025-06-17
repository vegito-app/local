import 'package:image_picker/image_picker.dart';

extension XFileImageLabel on XFile {
  String get imageLabel {
    final uri = Uri.decodeFull(path);

    // Récupérer uniquement la dernière portion du chemin avant les paramètres éventuels
    final cleanPath = uri.split('?').first;

    // Extraire la portion filename.ext en supprimant un éventuel préfixe timestamp (13 chiffres + underscore)
    final RegExp pattern = RegExp(
        r'(?:\d{13}_)?([\w-]+(?:_[\w-]+)*)(?:\.(jpg|jpeg|png|webp|gif))?',
        caseSensitive: false);
    final match = pattern.allMatches(cleanPath).lastOrNull;

    final ret = match?.group(1) ?? 'unknown-image';
    return ret;
  }
}
