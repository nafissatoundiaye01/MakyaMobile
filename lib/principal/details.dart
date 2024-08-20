import 'dart:async';
import 'dart:convert';
import 'package:cafetariat/principal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import '../classes/client.dart';
import '../classes/produit.dart';
import 'package:http/http.dart' as http;

import '../classes/produitCommande.dart';

class DetailsPage extends StatefulWidget {
  final Produit produit;

  const DetailsPage({required this.produit});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int selectedFormatIndex = -1;
  int idProduit =0;
  int quantity = 1;
  bool isFavorited =
      false; // Use a boolean to indicate whether the product is favorited or not
  TextEditingController detailsController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
late Timer _timer;
bool isLoading =true;
  

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      favoris();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    detailsController.dispose();
    super.dispose();
  }

  String getProduitsCommandeAsString(ProduitCommande produitsCommande) {
    String res =
      "${produitsCommande.produit.id}:${produitsCommande.taille}:${produitsCommande.quantite}:${produitsCommande.details}";

    return res;
  }


  Future<void> gererFav() async {
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
      favoris: [],
    );

    final clientResponse = await http.get(
      Uri.parse('http://172.20.10.3:8080/clients/$idClient'),
    );

    if (clientResponse.statusCode == 200) {
      Map<String, dynamic> clientJson = json.decode(clientResponse.body);
      client = Client.fromJson(clientJson);
      if(isFavorited==true){
        final clientResponse = await http.post(
      Uri.parse('http://172.20.10.3:8080/client/retraitFav'),
      body: {
        'idClient':client.id.toString(),
        'idProduit':widget.produit.id.toString()
      }
      
    );
    if(clientResponse.statusCode==200){
      setState(() {
       isFavorited=!isFavorited;
      });
    }else{
      print('Erreur lors du retrait');
    }
      }else{
 final clientResponse = await http.post(
      Uri.parse('http://172.20.10.3:8080/client/ajoutFav'),
      body: {
        'idClient':client.id.toString(),
        'idProduit':widget.produit.id.toString()
      }
      
    );
    if(clientResponse.statusCode==200){
      setState(() {
       isFavorited=!isFavorited;
      });
    }else{
      print('Erreur lors de l\'ajout');
    }
      }

    } else {
      print("Erreur lors de la requete de recuperation du client");
    }
  }

    Future<void> favoris() async {
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
      favoris: [],
    );

    final clientResponse = await http.get(
      Uri.parse('http://172.20.10.3:8080/clients/$idClient'),
    );

    if (clientResponse.statusCode == 200) {
      Map<String, dynamic> clientJson = json.decode(clientResponse.body);
      client = Client.fromJson(clientJson);
      if(client.favoris.isNotEmpty){
      // Check if the product is in the client's favorites
      for(Produit fav in client.favoris){
      if (fav.id==widget.produit.id) {
        setState(() {
          isFavorited = true; // Update the isFavorited variable
          isLoading=false;
        });
      }else{
        setState(() {
          isLoading=false;
        });
      }
      }
      }else{
        setState(() {
          isLoading=false;
        });
      }
    } else {
      print("Erreur lors de la requete de recuperation du client");
    }
  }

Future<void> ajouterPanier() async {
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
        
        
      
    }else{
        print("Erreur lors de la requete de recuperation du client");
    }

  List<String> format = ["S", "M", "L"];
  String detail = detailsController.text;
  if(detail==""){
    detail="ras";
  }
  ProduitCommande pcO = ProduitCommande(
    id: idProduit,
    produit: widget.produit,
    taille: format[selectedFormatIndex],
    quantite: quantity,
    details: detail,
  );

  String pc = getProduitsCommandeAsString(pcO);

  try {
    final response = await http.post(
      Uri.parse('http://172.20.10.3:8080/produit/addPanier'),
      body: {'id': client.id.toString(), 'produitCommande': pc}, // Correction ici : client.id.toString()
    );

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ajout'),
            content: const Text('Produit ajouté au panier avec succès!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrincipalPage(currentIndex:2 ),
                    ),
                  );
                },
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      );
      setState(() {
        idProduit++;
      });
    } else {
      print('Échec de la requête : ${response.statusCode}');
    }
  
  } catch (e) {
    print('Erreur lors de l\'ajout du produit au panier : $e');
  }
  
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
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
                  child: isLoading
            ? Center(
                child: CircularProgressIndicator(), // Afficher le spinner lors du chargement
              )
            : IconButton(
                    onPressed: () {
                      gererFav();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(!isFavorited
                              ? 'Ajouté aux favoris'
                              : 'Retiré des favoris'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                    ),
                    color: Colors.black,
                    iconSize: 24,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.13,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    widget.produit.nom,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: const Color.fromARGB(255, 216, 97, 50)
                              .withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    widget.produit.description,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        widget.produit.photo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.produit.formats
                              .asMap()
                              .entries
                              .map((entry) {
                            final int index = entry.key;
                            final String format = entry.value;
                            final int nombresDispo =
                                widget.produit.nombresDispoParFormat[index];

                            final color = nombresDispo == 0
                                ? Colors.grey
                                : selectedFormatIndex == index
                                    ? const Color.fromARGB(255, 216, 97, 50)
                                    : Colors.white;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Material(
                                elevation: 5,
                                borderRadius: BorderRadius.circular(24),
                                color: color,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () {
                                    setState(() {
                                      if (nombresDispo > 0) {
                                        selectedFormatIndex = index;
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(format),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              elevation: selectedFormatIndex != -1 ? 5 : 0,
                              borderRadius: BorderRadius.circular(20),
                              color: selectedFormatIndex != -1
                                  ? Colors.white
                                  : Colors.grey,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: IconButton(
                                  onPressed: selectedFormatIndex == -1
                                      ? null
                                      : () {
                                          setState(() {
                                            if (quantity > 1) {
                                              quantity--;
                                            }
                                          });
                                        },
                                  icon: const Icon(Icons.remove),
                                  color: selectedFormatIndex == -1
                                      ? Colors.grey
                                      : Colors.black,
                                  iconSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              ' $quantity',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Material(
                              elevation: selectedFormatIndex != -1 ? 5 : 0,
                              borderRadius: BorderRadius.circular(20),
                              color: selectedFormatIndex != -1
                                  ? const Color.fromARGB(255, 216, 97, 50)
                                  : Colors.grey,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: IconButton(
                                  onPressed: selectedFormatIndex == -1
                                      ? null
                                      : () {
                                          setState(() {
                                            if (quantity <
                                                widget.produit
                                                        .nombresDispoParFormat[
                                                    selectedFormatIndex]) {
                                              quantity++;
                                            }
                                          });
                                        },
                                  icon: const Icon(Icons.add),
                                  color: selectedFormatIndex == -1
                                      ? Colors.grey
                                      : Colors.black,
                                  iconSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Add the TextField here
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            controller: detailsController,
                            onSubmitted: (value) {
                              // Handle the input when the user presses the "Done" button on the keyboard
                              // The entered value is available as "value"
                            },
                            decoration: InputDecoration(
                              labelText: 'Détails',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.88,
            left: screenWidth * 0.05,
            right: screenWidth * 0.5,
            child: Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
              ),
              child: selectedFormatIndex != -1
                  ? Column(children: [
                      const Text(
                        "Prix ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black26,
                        ),
                      ),
                      Text(
                        " ${(widget.produit.prixParFormat[selectedFormatIndex] * quantity).toStringAsFixed(2)} Fcfa",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    ])
                  : Container(),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.05,
            left: screenWidth * 0.5,
            right: 0,
            child: InkWell(
              onTap: selectedFormatIndex != -1
                  ? () {
                      print(detailsController.text);
                      ajouterPanier();
                    }
                  : () {
                      // Show SnackBar if no format is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez choisir un format d\'abord.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 216, 97, 50),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: Color.fromARGB(255, 0, 0, 0),
                        size: 24,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Ajouter au panier',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
