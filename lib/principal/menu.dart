import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../classes/produit.dart';
import '../principal.dart';
import 'commandes.dart';
import 'details.dart';
import 'favorite.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int selectedCircleIndex=-1;
  String selectedCategory = 'Tout';
  TextEditingController searchController = TextEditingController();
bool isLoading = true;
    late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Create and start the timer
    fetchCategories();
    fetchProducts();
    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      fetchProducts();
      fetchCategories();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }
  bool available(Produit produit) {
    int j = 0;
    for (int i = 0; i < produit.nombresDispoParFormat.length; i++) {
      if (produit.nombresDispoParFormat[i] == 0) {
        j++;
      }
    }
    if (j == produit.nombresDispoParFormat.length) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://172.20.10.3:8080/products'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        List<Produit> productList = List<Produit>.from(jsonList.map((json) => Produit.fromJson(json)));

        setState(() {
          produits = productList;
          if (selectedCategory == 'Tout') {
            produitsFiltres = productList;
          } else {
            produitsFiltres = productList.where((produit) => produit.categorie == selectedCategory).toList();
          }
          isLoading = false;
        });
      } else {
        print('Échec de la requête : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des produits : $e');
    }
  }

  Future<void> fetchCategories() async {
  try {
    final response = await http.get(Uri.parse('http://172.20.10.3:8080/categories'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
       
      List<String> namesList = jsonResponse.map((data) => data['nom'] as String).toList();
      List<String> photosList = jsonResponse.map((data) => data['photo'] as String).toList();
     
      setState(() {
        circleImages = photosList;
        circleNames = namesList;
      });
    } else {
      print('Échec de la requête : ${response.statusCode}');
    }
  } catch (e) {
    print('Erreur lors de la récupération des catégories : $e');
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

  List<String> circleImages = [];
  List<String> circleNames = [];
  List<Produit> produits = [];
  List<Produit> produitsFiltres = [];

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
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrincipalPage(currentIndex: 2)),
                    );
                  },
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.black.withOpacity(0.3),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterProducts(value);
              },
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.24,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < circleImages.length; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCircleIndex = i;
                          onCircleTap(circleNames[i]);
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedCircleIndex == i
                                  ? const Color.fromARGB(255, 216, 97, 50)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/${circleImages[i]}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            circleNames[i],
                            style: TextStyle(
                              fontSize: 12,
                              color: selectedCircleIndex == i
                                  ? const Color.fromARGB(255, 216, 97, 50)
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
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
              top: screenHeight * 0.44,
              left: screenWidth * 0.1,
              child: Text(
                selectedCircleIndex == -1
                    ? 'Tout'
                    : circleNames[selectedCircleIndex],
                style:
                    const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              )),
          Positioned(
              top: screenHeight * 0.5,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              bottom: screenHeight * 0.01,
              child: isLoading
            ? Center(
                child: CircularProgressIndicator(), // Afficher le spinner lors du chargement
              )
            : selectedCircleIndex == -1
                  ? produits.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 boîtes par ligne
                            mainAxisSpacing:
                                16, // Espace vertical entre les boîtes
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
                                if (available(produit)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsPage(produit: produit),
                                    ),
                                  );
                                } else {
                                  // Afficher un message si le produit est indisponible dans tous les formats
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Produit indisponible'),
                                        content: Text(
                                            'Ce produit est actuellement indisponible.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Fermer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Container(
                                width: screenWidth *
                                    0.4, // Moitié de l'écran pour deux boîtes par ligne
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: available(produit)
                                      ? Colors.white
                                      : const Color.fromARGB(
                                          255, 159, 159, 159),
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
                                          color: Colors
                                              .white, // Fond blanc du ClipOval
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
                      : Center(
                          child: Column(children: [
                          ClipOval(
                            child: Container(
                              width: screenWidth * 0.6,
                              height: screenWidth * 0.6,
                              color: Colors.white10, // Fond blanc du ClipOval
                              child: Image.asset(
                                'assets/images/produits/dommage.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            'Aucun produit disponible ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ]))
                  : produitsFiltres.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 boîtes par ligne
                            mainAxisSpacing:
                                16, // Espace vertical entre les boîtes
                            crossAxisSpacing:
                                16, // Espace horizontal entre les boîtes
                            childAspectRatio:
                                0.7, // Ratio hauteur/largeur pour les boîtes
                          ),
                          itemCount: produitsFiltres.length,
                          itemBuilder: (context, index) {
                            final produit = produitsFiltres[index];
                            return GestureDetector(
                              onTap: () {
                                if (available(produit)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsPage(produit: produit),
                                    ),
                                  );
                                } else {
                                  // Afficher un message si le produit est indisponible dans tous les formats
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Produit indisponible'),
                                        content: Text(
                                            '${produit.nom} est actuellement indisponible.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Fermer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Container(
                                width: screenWidth *
                                    0.4, // Moitié de l'écran pour deux boîtes par ligne
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: available(produit)
                                      ? Colors.white
                                      : const Color.fromARGB(
                                          255, 159, 159, 159),
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
                                          color: Colors
                                              .white, // Fond blanc du ClipOval
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
                      : Center(
                          child: Column(children: [
                          ClipOval(
                            child: Container(
                              width: screenWidth * 0.6,
                              height: screenWidth * 0.6,
                              color: Colors.white10, // Fond blanc du ClipOval
                              child: Image.asset(
                                'assets/images/produits/dommage.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(searchController.text.isEmpty?
                            'Aucun produit disponible dans cette catégorie':'Aucun produit ${searchController.text} trouvé dans ${selectedCategory}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ]))),
        ],
      ),
    );
  }

  void onCircleTap(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'Tout') {
        produitsFiltres = produits;
      } else {
        produitsFiltres = produits.where((produit) => produit.categorie == category).toList();
      }
    });
  }

  void filterProducts(String query) {
    List<Produit> filteredList;
    if (selectedCircleIndex==-1) {
      print(query);
      filteredList = produits
          .where((produit) =>  produit.nom.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print(filteredList);
    } else {
      filteredList = produits
          .where((produit) => produit.categorie == selectedCategory && produit.nom.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      produitsFiltres = filteredList;
    });
  }
}



