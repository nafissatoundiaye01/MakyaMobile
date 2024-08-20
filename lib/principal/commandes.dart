import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../classes/commande.dart';
import '../classes/produitCommande.dart';

class CommandesPage extends StatefulWidget {
  @override
  _CommandesPageState createState() => _CommandesPageState();
}

String getProductNames(List<ProduitCommande> produitsCommande) {
  String names = '';
  for (var produitCommande in produitsCommande) {
    names +=
        '${produitCommande.quantite}x${produitCommande.produit.nom}(${produitCommande.taille}), ';
  }
  return names.substring(
      0, names.length - 2); // Remove the last comma and space
}

double getTotal(List<ProduitCommande> produitsCommande) {
  double total = 0;
  for (var produitCommande in produitsCommande) {
    final produit = produitCommande.produit;
    int index = -1;
    if (produitCommande.taille == "S") {
      index = 0;
    } else if (produitCommande.taille == "M") {
      index = 1;
    } else if (produitCommande.taille == "L") {
      index = 2;
    }
    if (index != -1) {
      total += produit.prixParFormat[index] * produitCommande.quantite;
    } else {
      return 0.0;
    }
  }
  return total;
}

class _CommandesPageState extends State<CommandesPage> {
  bool isVide = true;
  bool isLoading = true;
  bool pressed = false;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    commandesList();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      commandesList();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  List<Commande> commandes = [];
  List<Commande> commandesAttente = [];

  Future<void> commandesList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idClient = prefs.getInt('clientData');

      final response = await http.post(
        Uri.parse('http://172.20.10.3:8080/produit/commandes'),
        body: {'id': idClient.toString()},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        List<Commande> commandeList = List<Commande>.from(
            jsonList.map((json) => Commande.fromJson(json)));
        print(commandeList);
        setState(() {
          isVide = commandeList.isEmpty;
          isLoading = false;
          commandes = List.from(commandeList.reversed);
        });
      } else {
        print('Échec de la requête : ${response.statusCode}');
      }
    } catch (e) {}
  }

  Future<void> commandesAttenteList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idClient = prefs.getInt('clientData');

      final response = await http.post(
        Uri.parse('http://172.20.10.3:8080/produit/commandesAttente'),
        body: {'id': idClient.toString()},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        List<Commande> commandeList = List<Commande>.from(
            jsonList.map((json) => Commande.fromJson(json)));
        setState(() {
          commandesAttente = List.from(commandeList.reversed);
          isLoading = false;
        });
      } else {
        print('Échec de la requête : ${response.statusCode}');
      }
    } catch (e) {}
  }

  String generateRecuNumber() {
    int randomNum = Random().nextInt(90000000) + 1000000;
    int randomNum2 = Random().nextInt(9000000) + 1000000;

    return "$randomNum-$randomNum2";
  }

  String addSpaceBetweenCharacters(String input, String space) {
    if (input.isEmpty || space.isEmpty) {
      return input;
    }

    return input.split('').join(space);
  }

  Future<Uint8List> generateReceiptPdf(Commande commande) async {
    final pdf = pw.Document();

    // Obtenir la largeur et la hauteur de la page PDF
    final ByteData imageData =
        await rootBundle.load('assets/images/codeBarre.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();

    final ByteData imageData2 = await rootBundle.load('assets/images/home.png');
    final Uint8List imageBytes2 = imageData2.buffer.asUint8List();

    // Ajouter le contenu du reçu au PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          final List<pw.Widget> content = [
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                pw.ClipOval(
                  child: pw.SizedBox(
                    width: 100,
                    height: 100,
                    child: pw.Image(pw.MemoryImage(imageBytes2)),
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Text('Makya ESMT', style: const pw.TextStyle(fontSize: 40)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Image(pw.MemoryImage(imageBytes)),
            pw.SizedBox(height: 10),
            pw.Text(
              addSpaceBetweenCharacters(generateRecuNumber(), "  "),
              style: const pw.TextStyle(fontSize: 24),
            ),
            pw.SizedBox(height: 10),
            pw.Text('MK_${commande.id}',
                style: const pw.TextStyle(fontSize: 35)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Date: ${commande.date}',
                    style: const pw.TextStyle(fontSize: 24)),
                pw.Text(
                    'Heure: ${commande.heure.hour}:${commande.heure.minute}',
                    style: const pw.TextStyle(fontSize: 24)),
              ],
            ),
            pw.SizedBox(height: 30),
          ];

          for (var produitCommande in commande.produitsCommande) {
            final produitText =
                '${produitCommande.produit.nom} (${produitCommande.taille})';
            final quantiteText =
                '${produitCommande.quantite}x ${produitCommande.produit.prixParFormat[getIndexForTaille(produitCommande.taille)]} Fcfa';

            content.add(
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      produitText,
                      style: const pw.TextStyle(fontSize: 24),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      quantiteText,
                      style: const pw.TextStyle(fontSize: 26),
                      textAlign: pw.TextAlign.right, // Align text to the right
                    ),
                  ),
                ],
              ),
            );
          }

          content.addAll([
            pw.SizedBox(height: 60),
            pw.Text('Total: ${getTotal(commande.produitsCommande)} Fcfa',
                style: const pw.TextStyle(fontSize: 30)),
          ]);

          return pw.Column(children: content);
        },
      ),
    );

    // Générer le PDF en bytes
    final pdfBytes = await pdf.save();

    // Lancer l'impression du PDF
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);

    return pdfBytes;
  }

  Future<void> repasserCommande(Commande commande) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idClient = prefs.getInt('clientData');

      final response = await http.post(
        Uri.parse('http://172.20.10.3:8080/produit/repasserCommande'),
        body: {
          'idClient': idClient.toString(),
          'idCommande': commande.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Commande"),
              content: Text(response.body),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    commandesList();
                  },
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      } else {
        print('Échec de la requête : ${response.statusCode}');
      }
    } catch (e) {}
  }

  int getIndexForTaille(String taille) {
    switch (taille) {
      case "S":
        return 0;
      case "M":
        return 1;
      case "L":
        return 2;
      default:
        return 0; // Ou une valeur par défaut si la taille ne correspond à aucune des valeurs attendues
    }
  }

  void _showCommandeDetailsDialog(Commande commande) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails de la commande MK_${commande.id.toString()}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Date: ${commande.date} Heure: ${commande.heure.format(context)}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              for (var produitCommande in commande.produitsCommande)
                ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(produitCommande.produit.photo),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  title: Text(
                    produitCommande.produit.nom,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Format: ${produitCommande.taille}'),
                      Text('Quantité: ${produitCommande.quantite}'),
                      Text(
                        'Total: ${(produitCommande.quantite * produitCommande.produit.prixParFormat[getIndexForTaille(produitCommande.taille)]).toString()} Fcfa',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              Text(
                'Montant total: ${getTotal(commande.produitsCommande).toString()} Fcfa',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Fermer',
                style: TextStyle(color: Color.fromARGB(255, 196, 80, 13)),
              ),
            ),
            TextButton(
              onPressed: () {
                repasserCommande(commande);
              },
              child: const Text(
                'Repasser Commande',
                style: TextStyle(color: Color.fromARGB(255, 223, 154, 88)),
              ),
            ),
            TextButton(
              onPressed: () async {
                final pdfBytes = await generateReceiptPdf(commande);

                // Lancez l'impression du PDF
                Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfBytes);
              },
              child: const Text(
                'Générer Reçu',
                style: TextStyle(color: Color.fromARGB(255, 46, 109, 226)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.02,
            left: screenWidth * 0.05,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: Colors.black,
                    iconSize: 24,
                  ),
                ),
                SizedBox(width: screenWidth * 0.65),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.13,
            left: screenWidth * 0.05,
            child: const Text(
              'Commandes Récentes',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
          if (!pressed)
            isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(), // Afficher le spinner lors du chargement
                  )
                : !isVide
                    ? Positioned(
                        top: screenHeight * 0.25,
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                        bottom: screenHeight * 0.01,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: screenHeight * 0.8,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 16,
                            childAspectRatio: 4,
                          ),
                          itemCount: commandes.length,
                          itemBuilder: (context, index) {
                            final commande = commandes[index];
                            return GestureDetector(
                              onTap: () {
                                _showCommandeDetailsDialog(commande);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MK_${commande.id.toString()}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Color.fromARGB(255, 3, 113, 176),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Montant: ${getTotal(commande.produitsCommande).toString()} Fcfa \n'
                                      'Produits: ${getProductNames(commande.produitsCommande)}\n'
                                      'Date: ${commande.date} Heure: ${commande.heure.format(context)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Aucune commande précédente.',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
          Positioned(
              top: screenHeight * 0.2,
              right: screenWidth * 0.05,
              child: ElevatedButton(
                onPressed: commandes.isNotEmpty
                    ? !pressed
                        ? () {
                            setState(() {
                              commandesAttenteList();
                              pressed = true;
                              isLoading = true;
                            });
                          }
                        : () {
                            setState(() {
                              commandesList();
                              pressed = false;
                            });
                          }
                    : null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        // Couleur du fond lorsque le bouton est désactivé
                        return Colors.grey;
                      } else {
                        // Couleur du fond lorsque le bouton est activé (orange dans ce cas)
                        return Color.fromARGB(255, 180, 92, 20);
                      }
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Ajoutez le rayon souhaité ici
                    ),
                  ),
                ),
                child: Text(
                  !pressed ? 'Commandes en attente' : 'Toutes les Commandes',
                  style: TextStyle(fontSize: 15),
                ),
              )),
          if (pressed)
            isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(), // Afficher le spinner lors du chargement
                  )
                : commandesAttente.isNotEmpty
                    ? Positioned(
                        top: screenHeight * 0.25,
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                        bottom: screenHeight * 0.01,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: screenHeight * 0.8,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 16,
                            childAspectRatio: 4,
                          ),
                          itemCount: commandesAttente.length,
                          itemBuilder: (context, index) {
                            final commande = commandesAttente[index];
                            return GestureDetector(
                              onTap: () {
                                _showCommandeDetailsDialog(commande);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MK_${commande.id.toString()}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Color.fromARGB(255, 3, 113, 176),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Montant: ${getTotal(commande.produitsCommande).toString()} Fcfa \n'
                                      'Produits: ${getProductNames(commande.produitsCommande)}\n'
                                      'Date: ${commande.date} Heure: ${commande.heure.format(context)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Aucune commande en Attente précédente',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
        ],
      ),
    );
  }
}
