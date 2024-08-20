import 'dart:convert';
import 'dart:io';
import 'package:cafetariat/main.dart';
import 'package:cafetariat/principal/commandes.dart';
import 'package:cafetariat/principal/favorite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../classes/client.dart';
import '../principal.dart';
import 'chat.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  File? _image;
  String prenom = "";

  @override
  void initState() {
    super.initState();
    donnees();
  }

  Future<void> donnees() async {
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
        setState(() {
        prenom = "${client.prenom} ${client.nom}";
      });
      
    }else{
        print("Erreur lors de la requete de recuperation du client");
    }
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
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PrincipalPage(currentIndex: 2),
                      ),
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: IconButton(
                    icon: const Icon(
                      size:30,
                      Icons.person_pin,
                      color: Color.fromARGB(255, 183, 72, 28),
                    ),
                    onPressed: () {
                      _getImageFromGallery();
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  prenom,
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconTextButton(
                      icon: Icons.favorite,
                      text: 'Mes favoris',
                      direction: FavoritePage(),
                    ),
                    IconTextButton(
                        icon: Icons.schedule,
                        text: 'Mes commandes récentes',
                        direction: CommandesPage()),
                    IconTextButton(
                      icon: Icons.chat,
                      text: 'Questions/Réponses',
                      direction: ChatPage(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () {
                          // Ajoutez ici l'action à effectuer lors de l'appui sur la ligne de déconnexion
                          _confirmLogout(context);
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.exit_to_app_rounded,
                              color: Color.fromARGB(255, 183, 72, 28),
                            ),
                            SizedBox(width: 8),
                            Text('Déconnexion',style: TextStyle(fontSize: 20),),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> fetchPrenomFromDatabase() async {
    await Future.delayed(const Duration(seconds: 2));
    return 'Wos le BG';
  }

  Future<void> _getImageFromGallery() async {
    if (await Permission.photos.request().isGranted) {
      try {
        final pickedImage = await ImagePicker().getImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        setState(() {
          if (pickedImage != null) {
            _image = File(pickedImage.path);
          } else {
            print('Aucune image sélectionnée.');
          }
        });
      } catch (e) {
        print('Erreur lors de la sélection d\'une image : $e');
      }
    } else {
      print('Permission d\'accès à la galerie refusée.');
    }
  }
}

Future<void> _confirmLogout(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Déconnexion'),
            onPressed: () {
              Navigator.of(context).pop(); // Ferme le dialogue de confirmation
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyApp(),
                ),
              ); // Appelle la méthode de déconnexion réelle
            },
          ),
        ],
      );
    },
  );
}

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget direction;

  IconTextButton(
      {required this.icon, required this.text, required this.direction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => direction,
            ),
          );
        
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color.fromARGB(255, 183, 72, 28),
            ),
            const SizedBox(width: 8),
            Text(text,style: const TextStyle(fontSize: 20),),
          ],
        ),
      ),
    );
  }
}
