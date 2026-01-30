import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfInvoiceService {
  Future<Uint8List> generateInvoice(Map<String, dynamic> order) async {
    final pdf = pw.Document();
    final items = order['order_items'] as List;
    final date = DateTime.parse(order['created_at']);
    final total = order['total_amount'];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("ROMA UNIFORMS", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text("INVOICE", style: const pw.TextStyle(fontSize: 24, color: PdfColors.red)),
                ],
              ),
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 20),

              // DETAILS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Handle potential nulls safely, though schema should ensure they exist
                      pw.Text("To: ${order['profiles'] != null ? order['profiles']['full_name'] ?? 'Guest' : 'Guest'}"),
                      pw.Text("Tel: ${order['profiles'] != null ? order['profiles']['phone_number'] ?? 'N/A' : 'N/A'}"),
                      pw.Text("Loc: ${order['delivery_address'] ?? 'Pickup'}"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Order #: ${order['id'].toString().substring(0, 8)}"),
                      pw.Text("Date: ${DateFormat('yyyy-MM-dd').format(date)}"),
                      pw.Text("Status: ${order['status'].toString().toUpperCase()}"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // TABLE
              pw.Table.fromTextArray(
                headers: ['Item', 'Qty', 'Unit Price', 'Total'],
                data: items.map((item) {
                  final p = item['products'];
                  // Handle potential null product safely
                  final pName = p != null ? p['name'] : 'Unknown Product';
                  final lineTotal = (item['quantity'] * item['unit_price']);
                  return [
                    pName,
                    item['quantity'].toString(),
                    "KES ${item['unit_price']}",
                    "KES $lineTotal",
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 20),

              // TOTAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text("GRAND TOTAL:  ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text("KES $total", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                ],
              ),
              pw.Spacer(),
              
              // FOOTER
              pw.Divider(color: PdfColors.grey),
              pw.Center(child: pw.Text("Thank you for racing with ROMA.", style: const pw.TextStyle(color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Print or Share
  Future<void> printInvoice(Map<String, dynamic> order) async {
    final bytes = await generateInvoice(order);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Invoice_${order['id'].toString().substring(0, 8)}.pdf',
    );
  }
}
