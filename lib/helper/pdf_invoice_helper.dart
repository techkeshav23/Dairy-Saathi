import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:my_order_pro/helper/number_to_words.dart';

class PdfInvoiceHelper {
  static Future<void> shareInvoice({
    required String docTitle,
    required String invoiceNo,
    required DateTime date,
    required String partyName,
    String partyGstin = '',
    String partyAddress = '',
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double cgst,
    required double sgst,
    double igst = 0,
    required double total,
    String shopName = 'MY ORDER PRO',
    String shopAddress = '',
    String shopGstin = '',
  }) async {
    final bytes = await _build(
      docTitle: docTitle,
      invoiceNo: invoiceNo,
      date: date,
      partyName: partyName,
      partyGstin: partyGstin,
      partyAddress: partyAddress,
      items: items,
      subtotal: subtotal,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      total: total,
      shopName: shopName,
      shopAddress: shopAddress,
      shopGstin: shopGstin,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_$invoiceNo.pdf');
    await file.writeAsBytes(bytes);

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice_$invoiceNo.pdf',
    );
  }

  static Future<void> printInvoice({
    required String docTitle,
    required String invoiceNo,
    required DateTime date,
    required String partyName,
    String partyGstin = '',
    String partyAddress = '',
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double cgst,
    required double sgst,
    double igst = 0,
    required double total,
    String shopName = 'MY ORDER PRO',
    String shopAddress = '',
    String shopGstin = '',
  }) async {
    final bytes = await _build(
      docTitle: docTitle,
      invoiceNo: invoiceNo,
      date: date,
      partyName: partyName,
      partyGstin: partyGstin,
      partyAddress: partyAddress,
      items: items,
      subtotal: subtotal,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      total: total,
      shopName: shopName,
      shopAddress: shopAddress,
      shopGstin: shopGstin,
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  static Future<Uint8List> _build({
    required String docTitle,
    required String invoiceNo,
    required DateTime date,
    required String partyName,
    required String partyGstin,
    required String partyAddress,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double cgst,
    required double sgst,
    required double igst,
    required double total,
    required String shopName,
    String shopAddress = '',
    required String shopGstin,
  }) async {
    final pdf = pw.Document();
    final accentColor = PdfColor.fromHex('#1E3A8A');
    final greyBorder = PdfColors.grey400;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header Row
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      shopName,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    if (shopAddress.isNotEmpty) pw.SizedBox(height: 4),
                    if (shopAddress.isNotEmpty)
                      pw.Text(
                        shopAddress,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (shopGstin.isNotEmpty) pw.SizedBox(height: 4),
                    if (shopGstin.isNotEmpty)
                      pw.Text(
                        'GSTIN: $shopGstin',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      docTitle,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Invoice No: $invoiceNo'),
                    pw.Text(
                      'Date: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Bill To Block
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: greyBorder),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Bill To:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  partyName,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (partyAddress.isNotEmpty) pw.SizedBox(height: 4),
                if (partyAddress.isNotEmpty) pw.Text(partyAddress),
                if (partyGstin.isNotEmpty) pw.SizedBox(height: 4),
                if (partyGstin.isNotEmpty) pw.Text('GSTIN: $partyGstin'),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Itemised Table
          pw.TableHelper.fromTextArray(
            headers: ['S.No', 'Item', 'HSN', 'Qty', 'Rate', 'GST%', 'Amount'],
            data: List<List<String>>.generate(items.length, (index) {
              final item = items[index];
              return [
                (index + 1).toString(),
                item['name']?.toString() ?? '',
                item['hsn']?.toString() ?? '',
                item['qty']?.toString() ?? '0',
                '₹${item['rate']?.toString() ?? '0.00'}',
                '${item['gst_percent']?.toString() ?? '0'}%',
                '₹${item['amount']?.toString() ?? '0.00'}',
              ];
            }),
            border: pw.TableBorder.all(color: greyBorder),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: accentColor),
            cellAlignment: pw.Alignment.centerRight,
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
            },
            cellPadding: const pw.EdgeInsets.all(6),
          ),
          pw.SizedBox(height: 16),

          // Right-aligned Totals Block
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 220,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _buildTotalRow('Subtotal', subtotal),
                  _buildTotalRow('CGST', cgst),
                  _buildTotalRow('SGST', sgst),
                  if (igst > 0) _buildTotalRow('IGST', igst),
                  pw.Divider(color: greyBorder),
                  _buildTotalRow(
                    'Grand Total',
                    total,
                    isBold: true,
                    color: accentColor,
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 24),

          // Amount in Words Line
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Amount in Words:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                amountInWords(total),
                style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Powered by CodeBlimp',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTotalRow(
    String label,
    double value, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
          pw.Text(
            '₹${value.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}