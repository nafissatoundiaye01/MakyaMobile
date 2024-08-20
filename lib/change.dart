import 'dart:convert';

import 'package:cafetariat/principal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'classes/client.dart';


class ChangePage extends StatefulWidget {
  final int id;

  ChangePage({
    required this.id
  });

  @override
  _ChangePageState createState() => _ChangePageState();
}


class _ChangePageState extends State<ChangePage> {
  String _newPassword = '';
  String _confirmPassword = '';

  bool _passwordsMatch = true; // Variable pour vérifier si les mots de passe correspondent

  Future<void> _changePassword() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

    final clientResponse = await http.post(
        Uri.parse('http://172.20.10.3:8080/users/changePassword'),
        body:  {
        'id': widget.id.toString(),
        'password':_newPassword
        },
      );
      if (clientResponse.statusCode == 200) {
      // Si la requête a réussi (statut 200)
      Map<String, dynamic> clientJson = json.decode(clientResponse.body);
        Client client = Client.fromJson(clientJson);
      // Stocker le JSON dans SharedPreferences en tant que variable de session
      prefs.setInt('clientData', client.id);
      // ignore: use_build_context_synchronously
      Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrincipalPage(currentIndex: 0)),
                    );
      print(prefs.get('clientData'));
    } else {
      // Si la requête a échoué, afficher le message d'erreur
      print('Erreur lors de la requête : ${clientResponse.statusCode}');
    }
    print('Nouveau mot de passe : $_newPassword');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final boxWidth = screenWidth;
    final boxHeight = screenHeight * 0.4;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 211, 100, 9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0.0),
                  topRight: Radius.circular(0.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: boxHeight - boxHeight / 5,
            left: (boxWidth - boxHeight / 2) / 2,
            child: ClipOval(
              child: Container(
                width: boxHeight / 2,
                height: boxHeight / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/connexion.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: boxHeight * 0.45,
            left: boxWidth * 0.2,
            child: const Text(
              'Makya ESMT',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.6,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Column(
              children: [
                const Text(
                  'Nouveau mot de passe',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      _newPassword = value;
                      _passwordsMatch = _newPassword == _confirmPassword; // Vérifier si les mots de passe correspondent
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Confirmer mot de passe',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      _confirmPassword = value;
                      _passwordsMatch = _newPassword == _confirmPassword; // Vérifier si les mots de passe correspondent
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Confirmer mot de passe'),
                ),
                if (!_passwordsMatch) // Afficher le message d'erreur si les mots de passe ne correspondent pas
                  const Text(
                    'Les mots de passe ne correspondent pas.',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _newPassword.isNotEmpty && _passwordsMatch
                      ? () {
                          _changePassword();
                        }
                      : null, // Le bouton est inactif si les conditions ne sont pas remplies
                  child:  const Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 197, 85, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
