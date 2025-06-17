String formatQuantity(double quantityKg) {
  int grams = (quantityKg * 1000).round();
  if (grams < 1000) {
    return '$grams';
  }
  double kilos = grams / 1000.0;
  if (kilos == kilos.roundToDouble()) {
    return kilos.toStringAsFixed(0);
  } else if ((kilos * 10).roundToDouble() == kilos * 10) {
    return kilos.toStringAsFixed(1);
  } else if ((kilos * 100).roundToDouble() == kilos * 100) {
    return kilos.toStringAsFixed(2);
  } else {
    return kilos.toStringAsFixed(3);
  }
}
