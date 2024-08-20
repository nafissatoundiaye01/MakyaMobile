import 'package:flutter/material.dart';
import 'package:cafetariat/principal/menu.dart';
import 'package:cafetariat/principal/panier.dart';
import 'package:cafetariat/principal/profil.dart';
import 'package:cafetariat/principal/solde.dart';



class PrincipalPage extends StatefulWidget {
  final int currentIndex;
  const PrincipalPage({required this.currentIndex});
  @override
  _PrincipalPageState createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex; // Initialize _currentIndex in initState
  }  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body:_getPage(_currentIndex), 
        
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Color.fromARGB(255, 183, 72, 28),
          unselectedItemColor: Colors.grey[400],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: 'Solde',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Panier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Moi',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return MenuPage(); 
      case 1:
        return SoldePage(); 
      case 2:
        return PanierPage(); 
      case 3:
        return ProfilPage(); 
      default:
        return Container();
    }
  }

  
}

