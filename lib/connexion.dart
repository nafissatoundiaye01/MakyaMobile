// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafetariat/change.dart';
import 'package:flutter/material.dart';
import 'principal.dart';
import 'package:http/http.dart' as http;

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  // ignore: unused_field
  bool _isLoggedIn = false;
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final FocusNode _loginFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  

  @override
  void initState() {
    super.initState();
    login();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  // Fonction pour effectuer l'appel HTTP d'authentification

  Future<String?> authenticateUser(String login, String password) async {
    final response = await http.post(
      Uri.parse('http://172.20.10.3:8080/users/authenticate'),
      body: {
        'login': login,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      // Authentification réussie, retourne la réponse sous forme de chaîne de caractères
      return response.body;
    } else {
      // Authentification échouée
      return null;
    }
  }

  Future<void> loginUser(String login, String password) async {
  String? responseString = await authenticateUser(login, password);
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (responseString != null) {
    print(responseString);
    int userId = int.parse(responseString.split(',')[4].split('=')[1].replaceAll(RegExp(r'[^0-9]'), ''));
    print(userId);
    int id = int.parse(responseString.split(',')[0].split('=')[1]);

    print('Authentification réussie. ID de la personne : $userId');

    final clientResponse = await http.get(
      Uri.parse('http://172.20.10.3:8080/clients/$userId'),
    );

    if (clientResponse.statusCode == 200) {
      print(clientResponse.body);
      // Convertir l'objet Client en JSON
      

      // Stocker le JSON dans SharedPreferences en tant que variable de session
      prefs.setInt('clientData', userId);
      //print(prefs.get('clientData'));
      if (password == 'changeme') {
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePage(id: id),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            // ignore: prefer_const_constructors
            builder: (context) => PrincipalPage(currentIndex: 0),
          ),
        );
      }
    } else {
      // Échec de récupération du client
      print('Échec de récupération du client. Code de statut : ${clientResponse.statusCode}');
    }
  } else {
    // L'authentification a échoué
    print('Échec d\'authentification');
  }
}


  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  @override
  void dispose() {
    _loginFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
            top: screenHeight * 0.53,
            left: screenWidth * 0.33,
            child: const Text(
              'Connexion',
              style: TextStyle(
                  fontSize: 30,
                  color: Color.fromARGB(255, 29, 49, 115),
                  fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            top: screenHeight * 0.63,
            left: screenWidth * 0.07,
            right: screenWidth * 0.07,
            child: Column(
              children: [
                TextFormField(
                  focusNode: _loginFocusNode,
                  onTap: () {
                    _loginFocusNode.requestFocus();
                  },
                  controller: _loginController,
                  decoration: const InputDecoration(
                    labelText: 'Login',
                    prefixIcon: Icon(Icons.person,
                        color: Color.fromARGB(255, 43, 55, 125)),
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  focusNode: _passwordFocusNode,
                  onTap: () {
                    _passwordFocusNode.requestFocus();
                  },
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock,
                        color: Color.fromARGB(255, 43, 55, 125)),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color.fromARGB(255, 41, 54, 127),
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                SizedBox(height: screenHeight * 0.08),
                ElevatedButton(
                  onPressed: () {
                    String login = _loginController.text;
                    String password = _passwordController.text;

                    loginUser(login, password);
                  }

                  /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrincipalPage(
                                currentIndex: 0,
                              )),
                    );*/
                  ,
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 197, 85, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
