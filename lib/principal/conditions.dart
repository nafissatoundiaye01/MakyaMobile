import 'package:flutter/material.dart';

class ConditionsPage extends StatefulWidget {
  const ConditionsPage();

  @override
  _ConditionsPageState createState() => _ConditionsPageState();
}

class _ConditionsPageState extends State<ConditionsPage> {
  @override
  void dispose() {
    super.dispose();
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
        child: Row(children: [
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
        ]),
      ),
      Positioned(
          top: screenHeight * 0.1,
          left: screenWidth * 0.05,
          child: Text(
            'Conditions Générales',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Color.fromARGB(255, 133, 133, 133)
                      .withOpacity(0.5), // Couleur de l'ombre
                  offset: const Offset(2, 2), // Décalage de l'ombre (x, y)
                  blurRadius: 3, // Flou de l'ombre
                ),
              ],
            ),
          )),
          Positioned(
          top: screenHeight * 0.18,
          left: screenWidth * 0.05,
          right: screenWidth*0.05,
          child: const Text(
            "En rechargeant le solde de portefeuille mobile, vous acceptez les conditions générales suivantes : Le montant de la recharge est non remboursable et doit être utilisé conformément aux services autorisés. Des frais de service peuvent s'appliquer en fonction du montant de la recharge. Assurez-vous de saisir le numéro de téléphone correct pour éviter toute erreur de transfert. Les recharges sont soumises à la disponibilité du service dans votre région. Nous ne sommes pas responsables des recharges effectuées sur des numéros de téléphone incorrects. En utilisant notre service, vous acceptez ces conditions.",
            style: TextStyle(
              fontSize: 20,
              
            ),
          ))
    ]));
  }
}
