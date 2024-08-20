import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../classes/client.dart';
import '../classes/produit.dart';
import 'details.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
bool isLoading = true;
late Timer _timer;
  @override
  void initState() {
    super.initState();
   
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      favoris();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  List<Produit> produits = [];

Future<void> favoris() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

 int? idClient = prefs.getInt('clientData');
 Client client =Client(id: 0, nom: "nom", prenom: "prenom", courriel: "courriel", classe: "classe", numero: 0, solde: 0, photo: "photo", favoris: []);
  // Utiliser la Map clientData pour désérialiser
  final clientResponse = await http.get(
      Uri.parse('http://172.20.10.3:8080/clients/$idClient'),
    );

    if (clientResponse.statusCode == 200) {
       Map<String, dynamic> clientJson = json.decode(clientResponse.body);
        client = Client.fromJson(clientJson);
        setState(() {
        produits = client.favoris; // Mettre à jour la liste produits
        isLoading = false;
      });
      
    }else{
        print("Erreur lors de la requete de recuperation du client");
    }
}

String getFormatsWithPriceGreaterThanZero(Produit produit) {
    String formatsWithPrice = '';
    for (int i = 0; i < produit.formats.length; i++) {
      if (produit.prixParFormat[i] > 0) {
        formatsWithPrice += '${produit.formats[i]}, ';
      }
    }
    return formatsWithPrice;
  }

  String getPriceGreaterThanZero(Produit produit) {
    String Price = '';
    for (int i = 0; i < produit.prixParFormat.length; i++) {
      if (produit.prixParFormat[i] > 0) {
        Price += '${produit.prixParFormat[i]}Fcfa, ';
      }
    }
    return Price;
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(children: [
      Positioned(
        top: screenHeight * 0.02,
        left: screenWidth * 0.05,
        child: Row(
          children: [
            // Container avec décoration pour le cercle et l'effet de relief
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
                  // Action souhaitée lorsque l'utilisateur appuie sur l'icône "back"
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
      Positioned(top: screenHeight*0.13, left: screenWidth*0.28, child: Row(children:[
        const Icon(Icons.favorite_border),SizedBox(width: screenWidth*0.01,),
       const Text('Favoris',style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),),
       SizedBox(width: screenWidth*0.01,),const Icon(Icons.favorite_border)
      ])
       ),
      Positioned(
            top: screenHeight * 0.2,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: screenHeight * 0.01,
            child: isLoading
            ? Center(
                child: CircularProgressIndicator(), // Afficher le spinner lors du chargement
              )
            :
            produits.isNotEmpty?  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 boîtes par ligne
                      mainAxisSpacing: 16, // Espace vertical entre les boîtes
                      crossAxisSpacing:
                          16, // Espace horizontal entre les boîtes
                      childAspectRatio:
                          0.7, // Ratio hauteur/largeur pour les boîtes
                    ),
                    itemCount: produits.length,
                    itemBuilder: (context, index) {
                      final produit = produits[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DetailsPage(produit: produit)),
                          );
                        },
                        child: Container(
                          width: screenWidth *
                              0.4, // Moitié de l'écran pour deux boîtes par ligne
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors
                                      .green, // Couleur verte pour le cercle
                                ),
                                child: ClipOval(
                                  child: Container(
                                    color:
                                        Colors.white, // Fond blanc du ClipOval
                                    child: Image.asset(
                                      produit.photo,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                produit.nom,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Formats : ${getFormatsWithPriceGreaterThanZero(produit)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Prix : ${getPriceGreaterThanZero(produit)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                
                    : const Center(
                        child: Text(
                          'Aucun produit favori.',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
          ),
    ]));
  }
}
