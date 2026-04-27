import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class PdfService {
  static pw.MemoryImage? _cachedLogo;
  static pw.Font? _cachedFont;
  static pw.Font? _cachedBoldFont;

  static Future<void> generateAndPrintReceipt(StudentModel student) async {
    final pdf = pw.Document();
    
    // Branding Colors
    const primaryRed = PdfColor.fromInt(0xFFE4284C);
    const slateNavy = PdfColor.fromInt(0xFF1A202C);
    
    // Attempt to load logo (Robust method for Web with Caching)
    if (_cachedLogo == null) {
      try {
        final ByteData bytes = await rootBundle.load('assets/images/logo.png');
        _cachedLogo = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (e) {
        print('PDF Logo Error: $e');
      }
    }
    final logoImage = _cachedLogo;

    final dateStr = DateFormat('dd-MMMM-yyyy').format(student.date);
    final receiptId = 'IV-${student.mobileNumber.substring(student.mobileNumber.length.clamp(4, 100) - 4)}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Load Google Fonts for Unicode support (Robust method with Caching)
    if (_cachedFont == null || _cachedBoldFont == null) {
      _cachedFont = await PdfGoogleFonts.robotoRegular();
      _cachedBoldFont = await PdfGoogleFonts.robotoBold();
    }
    final font = _cachedFont!;
    final boldFont = _cachedBoldFont!;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          height: 60,
                          child: pw.Image(logoImage),
                        )
                      else
                        pw.Text('IELTS UNIVERSITY', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: primaryRed)),
                      pw.SizedBox(height: 8),
                      pw.Text('3rd Floor, Sharif Complex, Habiganj', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Phone: 01870237734', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('Email: ieltsvarsityofficial@gmail.com', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('OFFICIAL RECEIPT', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryRed)),
                      pw.Text('Receipt No: $receiptId', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                      pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: primaryRed, thickness: 1.5),
              pw.SizedBox(height: 40),

              // Student Details Grid
              pw.Text('STUDENT INFORMATION', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: slateNavy)),
              pw.SizedBox(height: 16),
              pw.Table(
                border: const pw.TableBorder(bottom: pw.BorderSide(color: PdfColors.grey100, width: 0.5)),
                children: [
                  _buildTableRow('Full Name', student.fullName),
                  _buildTableRow('Contact Number', student.mobileNumber),
                  _buildTableRow('Enrolled Course', student.course),
                  _buildTableRow('Batch Name', student.batchName),
                  _buildTableRow('Time', student.time),
                  _buildTableRow('Due Amount', 'BDT ${student.dueAmount.toStringAsFixed(0)}'),
                ],
              ),
              
              pw.SizedBox(height: 60),

              // Payment Summary Box
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: pw.BoxDecoration(
                          color: primaryRed,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('AMOUNT PAID', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                            pw.SizedBox(height: 4),
                            pw.Text('BDT ${student.paidAmount.toStringAsFixed(0)}', 
                              style: pw.TextStyle(color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Container(
                        width: 150,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1)),
                        ),
                        padding: const pw.EdgeInsets.only(top: 8),
                        child: pw.Center(
                          child: pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey100),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('IELTS UNIVERSITY OFFICIAL', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryRed)),
                      pw.SizedBox(height: 4),
                      pw.Text('www.ieltsvarsity.com', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Turning Ambition into Achievement', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save PDF bytes once to avoid re-rendering multiple times by the browser
    final bytes = await pdf.save();
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Receipt_${student.fullName}_$receiptId',
    );

  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700, fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }
}

