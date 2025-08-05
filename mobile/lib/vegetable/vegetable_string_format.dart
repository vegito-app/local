/// Formatte une quantité en kilogrammes en une chaîne lisible.
///
/// Les règles de formatage sont les suivantes :
///
/// - si la quantité est inférieure à 1 Kg, on l'affiche en grammes sans
///   décimale.
/// - si la quantité est supérieure ou égale à 100 Kg, on l'affiche en
///   kilogrammes sans décimale.
/// - si la quantité a une précision de 0.01 (ex: 1.80), on l'affiche avec
///   2 décimales.
/// - sinon, on l'affiche avec 3 décimales (ex: 0.345).
///
/// Exemples :
///
/// - 0.5 => '500 g'
/// - 1.80 => '1.80 Kg'
/// - 100.00 => '100 Kg'
/// - 0.345 => '0.345 Kg'
String formatQuantity(double quantityKg) {
  int grams = (quantityKg * 1000).round();
  if (grams < 1000) {
    // moins de 1 Kg : affiche en grammes sans décimale
    return '$grams g';
  }
  if (quantityKg >= 100) {
    // 100 Kg ou plus : nombre rond sans décimale
    return '${quantityKg.toStringAsFixed(0)} Kg';
  }
  if ((quantityKg * 100).roundToDouble() == quantityKg * 100) {
    // affiche 2 décimales si la précision est au centième (ex: 1.80)
    return '${quantityKg.toStringAsFixed(2)} Kg';
  }
  // sinon 3 décimales (ex: 0.345)
  return '${quantityKg.toStringAsFixed(3)} Kg';
}
