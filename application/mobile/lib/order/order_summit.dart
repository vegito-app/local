import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../vegetable_upload/vegetable_model.dart';
import 'order_model.dart';

Future<Uint8List> generateSummaryPdf(
    List<Order> orders, Map<String, Vegetable> vegMap) async {
  final pdf = pw.Document();

  // Group orders by clientId
  final Map<String, List<Order>> ordersByClient = {};
  for (final order in orders) {
    ordersByClient.putIfAbsent(order.clientId, () => []).add(order);
  }

  pdf.addPage(
    pw.MultiPage(
      build: (context) {
        return [
          pw.Header(
              level: 0, child: pw.Text('Résumé logistique de la tournée')),
          for (final clientId in ordersByClient.keys) ...[
            pw.Paragraph(text: 'Client : $clientId'),
            pw.ListView.builder(
              itemCount: ordersByClient[clientId]!.length,
              itemBuilder: (context, index) {
                final order = ordersByClient[clientId]![index];
                final veg = vegMap[order.vegetableId];
                final vegName = veg?.name ?? 'Légume inconnu';
                return pw.Bullet(
                    text:
                        '$vegName x${order.quantity} — Statut : ${order.status}');
              },
            ),
            pw.SizedBox(height: 12),
          ],
        ];
      },
    ),
  );

  return pdf.save();
}
