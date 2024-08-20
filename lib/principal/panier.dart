import 'dart:async';
import 'dart:convert';

import 'package:cafetariat/principal/commandes.dart';
import 'package:cafetariat/principal/favorite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/client.dart';
import '../classes/commande.dart';
import '../classes/produitCommande.dart';

List<ProduitCommande> listeProduitCommande = [];

class PanierPage extends StatefulWidget {
  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  bool isVide = false;
  late Timer _timer;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);

    panier();
    // Create and start the timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      panier();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  String getProduitsCommandeAsString(ProduitCommande produitsCommande) {
    String res =
        "${produitsCommande.produit.id}:${produitsCommande.taille}:${produitsCommande.quantite}:${produitsCommande.details}";

    return res;
  }

  Future<void> valider() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idClient = prefs.getInt('clientData');

    final response = await http.post(
        Uri.parse('http://172.20.10.3:8080/produit/validerPanier'),
        body: {
          'id': idClient.toString(),
        });

    print(response.statusCode);

    if (response.statusCode == 200) {
      // ignore: unnecessary_null_comparison
      if (response.body != null) {
        setState(() {
          listeProduitCommande.clear();
          if (listeProduitCommande.isEmpty) {
            isVide = true;
          }
        });

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Validation'),
              content: Text(response.body),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Show an error message in case of failure
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Validation Echouée'),
            content: Text(response.body),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> removeProduitFromPanier(ProduitCommande produitCommande) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? idClient = prefs.getInt('clientData');
    Client client = Client(
        id: 0,
        nom: "nom",
        prenom: "prenom",
        courriel: "courriel",
        classe: "classe",
        numero: 0,
        solde: 0,
        photo: "photo",
        favoris: []);
    // Utiliser la Map clientData pour désérialiser
    final clientResponse = await http.get(
      Uri.parse('http://172.20.10.3:8080/clients/$idClient'),
    );

    if (clientResponse.statusCode == 200) {
      Map<String, dynamic> clientJson = json.decode(clientResponse.body);
      client = Client.fromJson(clientJson);
      final response = await http.post(
          Uri.parse('http://172.20.10.3:8080/produit/supprimerPanier'),
          body: {
            'id': client.id.toString(),
            'pcs': getProduitsCommandeAsString(produitCommande)
          });

      print(response.statusCode);
      if (response.statusCode == 200) {
        // ignore: unnecessary_null_comparison
        if (response.body != null) {
          setState(() {
            listeProduitCommande.remove(produitCommande);
            if (listeProduitCommande.isEmpty) {
              isVide = true;
            }
          });
        } else {
          setState(() {
            isVide = true;
          });
        }
      }
    }
  }

  Future<void> panier() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int? idClient = prefs.getInt('clientData');
      Client client = Client(
          id: 0,
          nom: "nom",
          prenom: "prenom",
          courriel: "courriel",
          classe: "classe",
          numero: 0,
          solde: 0,
          photo: "photo",
          favoris: []);
      // Utiliser la Map clientData pour désérialiser
      final clientResponse = await http.get(
        Uri.parse('http://172.20.10.3:8080/clients/$idClient'),
      );

      if (clientResponse.statusCode == 200) {
        Map<String, dynamic> clientJson = json.decode(clientResponse.body);
        client = Client.fromJson(clientJson);
        final response = await http.post(
            Uri.parse('http://172.20.10.3:8080/produit/panier'),
            body: {'id': client.id.toString()});

        if (response.statusCode == 200) {
          // ignore: unnecessary_null_comparison
          if (response.body != null) {
            Map<String, dynamic> panierJson = json.decode(response.body);
            Commande commande = Commande.fromJson(panierJson);

            setState(() {
              isVide = false;
              listeProduitCommande = commande.produitsCommande;
              if (listeProduitCommande.isEmpty) {
                isVide = true;
              } else {}
              print(listeProduitCommande);
            });
          } else {
            setState(() {
              isVide = true;
            });
          }
        } else {
          print('Échec de la requête : ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération du panier : $e');
    }
  }

  Future<Future<bool?>> showDeleteConfirmationDialog(
      ProduitCommande produitCommande) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le produit'),
          content: const Text(
              'Voulez-vous vraiment supprimer ce produit du panier ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Annuler la suppression
                setState(() {
                  selectedIndex = -1;
                });
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmer la suppression
                removeProduitFromPanier(produitCommande);
                setState(() {
                  selectedIndex = -1;
                });
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  double getTotalPanier() {
    double totalPanier = 0;
    for (var produitCommande in listeProduitCommande) {
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
        totalPanier += produit.prixParFormat[index] * produitCommande.quantite;
      } else {
        return 0.0;
      }
    }
    return totalPanier;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.08,
            left: screenWidth * 0.05,
            child: Text(
              'Makya.',
              style: TextStyle(
                fontSize: 30,
                color: const Color.fromARGB(255, 183, 72, 28),
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.08,
            right: screenWidth * 0.05,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoritePage()),
                    );
                  },
                  child: Icon(
                    Icons.favorite,
                    color: Colors.black.withOpacity(0.3),
                    size: 30,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CommandesPage()),
                    );
                  },
                  child: Icon(
                    Icons.schedule,
                    color: Colors.black.withOpacity(0.3),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.18,
            left: screenWidth * 0.1,
            child: const Text(
              'Panier',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
              top: screenHeight * 0.22,
              left: 0,
              right: 0,
              bottom: screenHeight * 0.01,
              child: !isVide
                  ? ListView.builder(
                      itemCount: listeProduitCommande.length,
                      itemBuilder: (context, index) {
                        final produitCommande = listeProduitCommande[index];
                        final produit = produitCommande.produit;
                        double total = 0.0;
                        if (produitCommande.taille == "S") {
                          total = produit.prixParFormat[0] *
                              produitCommande.quantite;
                        } else if (produitCommande.taille == "M") {
                          total = produit.prixParFormat[1] *
                              produitCommande.quantite;
                        } else if (produitCommande.taille == "L") {
                          total = produit.prixParFormat[2] *
                              produitCommande.quantite;
                        }

                        return GestureDetector(
                          // Utiliser un GestureDetector pour détecter les mouvements de balayage léger
                          onHorizontalDragUpdate: (details) {
                            // Balayage léger vers la droite
                            if (details.delta.dx > 10) {
                              setState(() {
                                // Mettre à jour l'index sélectionné pour la suppression
                                selectedIndex = index;
                              });
                            }
                          },
                          onHorizontalDragEnd: (details) {
                            // Remettre à zéro l'index sélectionné après le balayage léger
                            setState(() {
                              //selectedIndex = -1;
                            });
                            showDeleteConfirmationDialog(produitCommande);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: Matrix4.translationValues(
                              index == selectedIndex
                                  ? 100
                                  : 0, // Appliquer l'animation uniquement à l'élément sélectionné
                              0,
                              0,
                            ),
                            child: Container(
                              width: screenWidth * 0.9,
                              height: screenHeight * 0.1185,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(10),
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: screenWidth * 0.2,
                                    height: screenHeight * 0.1,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(produit.photo),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produit.nom,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 0),
                                        Text(
                                          'Quantité: ${produitCommande.quantite}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Format: ${produitCommande.taille}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Total: $total Fcfa',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Column(children: [
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      Image.asset(
                        'assets/images/produits/panier.png',
                        height: screenHeight * 0.4,
                        width: screenHeight * 0.7,
                      ),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      const Text(
                        'Oupss!! Ton Panier Est Vide',
                        style: TextStyle(fontSize: 24),
                      ),
                    ])),
          Positioned(
              bottom: screenHeight * 0.01,
              right: 0,
              child: GestureDetector(
                onTap: !isVide
                    ? () {
                        valider();
                      }
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Validation Echouée'),
                              content: const Text('Votre Panier est vide'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                child: Container(
                  width: screenWidth * 0.25,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 183, 72, 28),
                    borderRadius: const BorderRadius.only(
                      topLeft:
                          Radius.circular(30), // Coin supérieur gauche arrondi
                      bottomLeft:
                          Radius.circular(30), // Coin inférieur gauche arrondi
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Valider',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              )),
          if (!isVide)
            Positioned(
              top: screenHeight * 0.17,
              right: 0,
              child: Container(
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.06,
                  decoration: const BoxDecoration(
                    color:
                        Color.fromARGB(255, 183, 72, 28), // Couleur du bouton

                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                  ),
                  child: Center(
                    child: Text(
                      'Total: ${getTotalPanier()} Fcfa',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )),
            ),
        ],
      ),
    );
  }
}
