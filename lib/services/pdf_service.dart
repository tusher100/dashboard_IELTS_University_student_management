import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndPrintReceipt(StudentModel student) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('dd-MMM-yyyy HH:mm').format(student.createdAt ?? DateTime.now());
    final receiptId = 'IELTSU-${DateTime.now().millisecondsSinceEpoch}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('IELTS UNIVERSITY', 
                    style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                ),
                pw.Center(child: pw.Text('Official Payment Receipt', style: const pw.TextStyle(fontSize: 16))),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Receipt No: $receiptId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: $dateStr'),
                  ],
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
                _buildRow('Student Name', student.fullName),
                _buildRow('Mobile Number', student.mobileNumber),
                _buildRow('Course Type', student.course),
                _buildRow('Payment Plan', student.paymentPlan),
                _buildRow('Scholarship', student.scholarship),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TOTAL AMOUNT PAID', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('\$${student.amountPaid.toStringAsFixed(2)}', 
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.Center(
                  child: pw.Text('Thank you for choosing IELTS University!', 
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 150, child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Text(value),
        ],
      ),
    );
  }
}
