import 'dart:async';
import 'dart:convert';

import 'package:cafetariat/principal/commandes.dart';
import 'package:cafetariat/principal/favorite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../classes/client.dart';
import '../classes/transaction.dart';
import '../principal.dart';
import 'conditions.dart';

class SoldePage extends StatefulWidget {
  @override
  _SoldePageState createState() => _SoldePageState();
}

class _SoldePageState extends State<SoldePage> {



  double solde = 0;
  int selectedButtonIndex = 0;
  bool showRechargeTextField = false;
  bool showTransactionTextField = false;
  List<bool> isSelected = [true, false];
  bool changeNumber = false;
  bool agree = false;
  String numero = '';
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isVide = false;
  List<Transaction> transactions = [];
  late Timer _timer;

   Future<void> transaction() async {
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
        setState(() {
          numero=client.numero.toString();
          solde = client.solde;
        });
        final response = await http.post(Uri.parse('http://172.20.10.3:8080/solde/transactions'),
            body: {
              'id': client.id.toString()
            });

        if (response.statusCode == 200) {
          
          // ignore: unnecessary_null_comparison
          if (response.body != null) {
           List<dynamic> jsonList = json.decode(response.body);
          List<Transaction> transactionList =
              List<Transaction>.from(jsonList.map((json) => Transaction.fromJson(json)));
        
            setState(() {
              isVide=false;
              transactions = List.from(transactionList.reversed);
              if(transactions.isEmpty){
                isVide=true;
              }else{
                
              }
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
      print('Erreur lors de la récupération des transactions : $e');
    }
  }


     Future<void> recharger() async {
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
        setState(() {
          numero=client.numero.toString();
          solde = client.solde;
        });
        final response = await http.post(Uri.parse('http://172.20.10.3:8080/solde/incrementerSolde'),
            body: {
              'id': client.id.toString(),
              'montant': amountController.text
            });

        if (response.statusCode == 200) {
          // ignore: use_build_context_synchronously
          showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Solde'),
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
          
        } else {
          print('Échec de la requête : ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des transactions : $e');
    }
  }



  void _launchURL(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ConditionsPage()), // Navigate to ConditionsPage
    );
  }

  @override
  void initState() {
    super.initState();
    transaction();
    phoneNumberController.addListener(updateRechargeButtonState);
    amountController.addListener(updateRechargeButtonState);
    otpController.addListener(updateRechargeButtonState);

    // Écouter les changements dans la case à cocher
    phoneNumberController.addListener(updateRechargeButtonState);
    // Sélectionner le bouton "Mes Transactions" par défaut
    selectedButtonIndex = 1;
    showRechargeTextField = false;
    showTransactionTextField = true;
     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      
      transaction();
    });
  }

  void updateRechargeButtonState() {
    setState(() {});
  }

  bool isRechargeButtonEnabled() {
    if (isSelected[0]) {
      // Vérifier si Orange Money est sélectionné
      if (changeNumber) {
        if (phoneNumberController.text.isNotEmpty &&
            amountController.text.isNotEmpty &&
            otpController.text.isNotEmpty &&
            agree) {
          return true;
        }
      } else {
        if (amountController.text.isNotEmpty &&
            otpController.text.isNotEmpty &&
            agree) {
          return true;
        }
      }
    } else {
      // Vérifier si Wave est sélectionné
      if (changeNumber) {
        if (phoneNumberController.text.isNotEmpty &&
            amountController.text.isNotEmpty &&
            agree) {
          return true;
        }
      } else {
        if (amountController.text.isNotEmpty && agree) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    // Dispose of the controllers when they are no longer needed
    phoneNumberController.dispose();
    amountController.dispose();
    otpController.dispose();
    _timer.cancel();
    super.dispose();
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
                            MaterialPageRoute(
                                builder: (context) =>
                                    FavoritePage()),
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
                            MaterialPageRoute(
                                builder: (context) =>
                                    CommandesPage()),
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
                                builder: (context) =>
                                    PrincipalPage(currentIndex: 2)),
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
            top: screenHeight * 0.2,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    solde.toString(),
                    style: const TextStyle(fontSize: 50),
                  ),
                  const Text(
                    'Fcfa',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth * 0.3, // Ajuster la taille du bouton
                    height: screenWidth * 0.3, // Ajuster la taille du bouton
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButtonIndex = 0;
                          showRechargeTextField = true;
                          showTransactionTextField = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedButtonIndex == 0
                            ? const Color.fromARGB(255, 183, 72, 28)
                            : Colors.grey[200],
                        elevation: selectedButtonIndex == 0 ? 5 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Image.asset(
                            'assets/images/recharge.png',
                            width: screenWidth *
                                0.15, // Ajuster la taille de l'image
                            height: screenWidth *
                                0.15, // Ajuster la taille de l'image
                          ),
                          SizedBox(
                            height: screenHeight * 0.015,
                          ),
                          const Text(
                            'Recharger mon solde',
                            style: TextStyle(fontSize: 15),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      width: screenWidth *
                          0.03), // Ajouter un espace de 3% de la largeur de l'écran
                  SizedBox(
                    width: screenWidth * 0.3, // Ajuster la taille du bouton
                    height: screenWidth * 0.3, // Ajuster la taille du bouton
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButtonIndex = 1;
                          showRechargeTextField = false;
                          showTransactionTextField = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: selectedButtonIndex == 1
                            ? const Color.fromARGB(255, 183, 72, 28)
                            : Colors.grey[200],
                        elevation: selectedButtonIndex == 1 ? 5 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Image.asset(
                            'assets/images/transaction.png',
                            width: screenWidth *
                                0.15, // Ajuster la taille de l'image
                            height: screenWidth *
                                0.15, // Ajuster la taille de l'image
                          ),
                          SizedBox(
                            height: screenHeight * 0.015,
                          ),
                          const Text(
                            'Mes Transactions',
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showRechargeTextField)
            Positioned(
              top: screenHeight * 0.5,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              bottom: screenHeight * 0.01,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Choisissez un Opérateur',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    ToggleButtons(
                      isSelected: isSelected,
                      onPressed: (int index) {
                        setState(() {
                          isSelected[index] = !isSelected[index];
                          // Pour rendre l'effet de bascule, on désélectionne l'autre bouton
                          isSelected[1 - index] = !isSelected[index];
                        });
                      },
                      children: [
                        Container(
                          width: screenWidth * 0.4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected[0]
                                ? const Color.fromARGB(255, 203, 96, 54)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Orange Money',
                              style: TextStyle(
                                color:
                                    isSelected[0] ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected[1]
                                ? const Color.fromARGB(255, 8, 168, 212)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Wave',
                              style: TextStyle(
                                color:
                                    isSelected[1] ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.045,
                    ),
                    const Text(
                      'Confirmez Numéro de Téléphone',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    /**/
                    Container(
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.8, // Adjust the height as needed
                      child: TextField(
                        controller: phoneNumberController,
                        enabled:
                            changeNumber, // Enable or disable based on the checkbox value
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: numero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Transform.scale(
                          scale: 0.6, // Adjust the scale value as needed
                          child: Checkbox(
                            value: changeNumber,
                            onChanged: (value) {
                              setState(() {
                                changeNumber = value ?? false;
                              });
                            },
                          ),
                        ),
                        const Text(
                          'Changer numéro',
                          style: TextStyle(
                              fontSize: 12), // Adjust the font size as needed
                        ),
                        const Spacer(), // This will push the entire Row to the right
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.035),
                    const Text(
                      'Saisissez le Montant',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    
                    Container(
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.8, // Adjust the height as needed
                      child: TextField(
                        controller: amountController,
                        enabled:
                            true, // Enable or disable based on the checkbox value
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '1000Fcfa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    if (isSelected[0] == true)
                      Column(children: [
                        SizedBox(height: screenHeight * 0.035),
                        const Text(
                          'Saisissez le code OTP',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Container(
                          height: screenHeight * 0.08,
                          width:
                              screenWidth * 0.8, // Adjust the height as needed
                          child: TextField(
                            controller: otpController,
                            enabled:
                                true, // Enable or disable based on the checkbox value
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'code OTP',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    SizedBox(
                      height: screenHeight * 0.035,
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.8, // Adjust the scale value as needed
                          child: Checkbox(
                            value: agree,
                            onChanged: (value) {
                              setState(() {
                                agree = value ?? false;
                              });
                            },
                          ),
                        ),
                        const Text(
                          "J'ai lu et j'accepte les ",
                          style: TextStyle(
                            fontSize: 12, // Adjust the font size as needed
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Votre fonction à exécuter lors du clic
                            _launchURL(context);
                          },
                          child: const Text(
                            'conditions générales d\'utilisation.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        const Spacer(), // This will push the entire Row to the right
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.035,
                    ),
                    ElevatedButton(
                      onPressed: isRechargeButtonEnabled()
                          ? () {
                            recharger();
                            }
                          : null, // Désactiver le bouton si toutes les conditions ne sont pas remplies
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 203, 96, 54),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text('Recharger'),
                    )
                  ],
                ),
              ),
            ),
          if (showTransactionTextField)
          transactions.isNotEmpty?
            Positioned(
              top: screenHeight * 0.45,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              bottom: screenHeight * 0.01,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: screenHeight *
                      0.8, // Set the maximum width for each grid item
                  mainAxisSpacing: 5, // Vertical space between boxes
                  crossAxisSpacing: 16, // Horizontal space between boxes
                  childAspectRatio:
                      4, // Set the aspect ratio (width / height) for each grid item
                ),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return GestureDetector(
                    onTap: () {
                      // ... Action souhaitée lorsqu'on appuie sur une transaction
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            transaction.numeroTransaction,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 0),
                          Text(
                            'Montant: ${transaction.montant} Fcfa '
                            'Date: ${transaction.date} \n'
                            'Heure: ${transaction.heure.format(context)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ):  Positioned(
                        top: screenHeight*0.6,
                        left: screenWidth*0.08,
                        right: 0,
                        child: const Text(
                          'Aucune transaction effectuée',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
        ],
      ),
    );
  }
}
