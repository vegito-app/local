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
