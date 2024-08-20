import 'dart:typed_data';

import 'package:cafetariat/classes/commande.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Recu extends StatefulWidget {
  final Commande commande;

  Recu({required this.commande});

  @override
  _RecuState createState() => _RecuState();
}

class _RecuState extends State<Recu> {
  @override
  void initState() {
    super.initState();
    generateReceiptPdf(); // Appeler la fonction pour générer le PDF automatiquement au lancement de la page
  }

  Future<Uint8List> generateReceiptPdf() async {
    final pdf = pw.Document();

    // Ajoutez le contenu du reçu au PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Contenu du reçu de la commande ici: ${widget.commande.id}'),
        ),
      ),
    );

    // Générez le PDF en bytes
    final pdfBytes = await pdf.save();

    // Lancez l'impression du PDF
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);

    return pdfBytes;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Génération du reçu de commande'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Générez le PDF
              final pdfBytes = await generateReceiptPdf();

              // Lancez l'impression du PDF
              Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
            },
            child: Text('Reçu généré automatiquement'),
          ),
        ),
      ),
    );
  }
}
