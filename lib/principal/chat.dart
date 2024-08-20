
import 'package:cafetariat/classes/message.dart';
import 'package:flutter/material.dart';


class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.005, left: screenWidth * 0.05),
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
                  SizedBox(width: screenWidth * 0.07,),
                  const Text('Questions/Réponses', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)
                ],
              )
            ),
            SizedBox(height: screenHeight * 0.01,),
            const Text('Nous tentons de mieux vous orienter dans l\'utilisation de notre application!'),
            SizedBox(height: screenHeight * 0.01,),
             Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isCurrentUser = message.id == 1;

                  return ListTile(
                    title: Text(
                      message.message,
                      textAlign: isCurrentUser ? TextAlign.right : TextAlign.left,
                      style: TextStyle(fontSize: 20, color: isCurrentUser ? Colors.black : const Color.fromARGB(255, 173, 82, 21)),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _sendPredefinedMessage('Pour joindre notre service commercial, appelez le +221771308507 ou envoyez un mail au makya.resto@esmt.sn.');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 5,
                      ),
                      child: const Text(
                        'Service Commercial',
                        style: TextStyle(
                          color: Color.fromARGB(255, 173, 82, 21),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _sendPredefinedMessage('Pour passer une commande, veuillez consulter notre menu et sélectionner les articles que vous souhaitez commander. Pensez à vérifier votre solde!');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 5,
                      ),
                      child: const Text(
                        'Commande',
                        style: TextStyle(
                          color: Color.fromARGB(255, 173, 82, 21),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _sendPredefinedMessage('Votre Solde est rechargeable via OrangeMoney et Wave. Les frais de recharge sont débités de votre compte: lisez les conditions de rechargement.');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 5,
                      ),
                      child: const Text(
                        'Solde',
                        style: TextStyle(
                          color: Color.fromARGB(255, 173, 82, 21),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _sendPredefinedMessage('Votre restaurant scolaire est ouvert de 7h15 à 20h45.');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 5,
                      ),
                      child: const Text(
                        'Horaires',
                        style: TextStyle(
                          color: Color.fromARGB(255, 173, 82, 21),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                 
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendPredefinedMessage(String message) {
    Message messenger = Message(
      id: 1,
      message: message,
      date: '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
      heure: '${DateTime.now().hour}:${DateTime.now().minute}'
    );
    setState(() {
      _messages.add(messenger);
      Message reply = Message(
        id: 2,
        message: 'Pour plus d\'informations, contactez notre service client au +221771308507.',
        date: '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
        heure: '${DateTime.now().hour}:${DateTime.now().minute}'
      );
      _messages.add(reply);
    });
  }

 
}
