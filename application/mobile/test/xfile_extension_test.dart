import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vegito/xfile_extension.dart';

class FakeXFile extends XFile {
  FakeXFile(super.path);
}

void main() {
  group('XFileImageLabel', () {
    test('extrait le nom depuis un chemin local simple', () {
      final file = FakeXFile('/storage/emulated/0/Download/patate-3.jpg');
      expect(file.imageLabel, 'patate-3');
    });

    test('extrait le nom depuis une URL Firebase encodée', () {
      final file = FakeXFile(
          'https://firebasestorage.googleapis.com/v0/b/vegetables%2F5jtSdAib9isIJQN3p8RQgA0xJELm%2F1750134334196_patate-4.jpg?alt=media&token=abc');
      expect(file.imageLabel, 'patate-4');
    });

    test('retourne "unknown-image" si aucun nom valide trouvé', () {
      final file = FakeXFile('https://exemple.com/image.jpg?token=');
      expect(file.imageLabel, 'image');
    });

    test('supporte les fichiers sans extension explicite', () {
      final file = FakeXFile('https://cdn.site.com/images/photo_12345');
      expect(file.imageLabel, 'photo_12345');
    });
    test('supporte les fichiers sans extension explicite', () {
      final file = FakeXFile(
          'image_vegetables%2F5jtSdAib9isIJQN3p8RQgA0xJELm%2F1750148975614_patate-4.jpg?alt=media&amp;token=c8fda921-1f0c-42b2-8651-ed87d2ae1609');
      expect(file.imageLabel, 'patate-4');
    });
  });
}
