import 'package:cafetariat/classes/produitCommande.dart';
import 'package:flutter/material.dart';

class Commande {
  int id;
  String date;
  TimeOfDay heure;
  List<ProduitCommande> produitsCommande;

  Commande({
    required this.id,
    required this.date,
    required this.heure,
    required this.produitsCommande,
  });

  double getTotal() {
    double total = 0;
    for (var produitCommande in produitsCommande) {
      final produit = produitCommande.produit;
      final formatIndex = produit.formats.indexOf(produitCommande.taille);
      final produitTotal =
          produit.prixParFormat[formatIndex] * produitCommande.quantite;
      total += produitTotal;
    }
    return total;
  }



factory Commande.fromJson(Map<String, dynamic> json) {
  String heureString = json['heure'];
    TimeOfDay heure = _convertToTimeOfDay(heureString);
  return Commande(
    id: json['id'],
    date: json['date'],
    heure: heure, // Convertir la chaîne en TimeOfDay
    produitsCommande: List<ProduitCommande>.from(json['produitsCommande']
        .map((produitCommande) => ProduitCommande.fromJson(produitCommande))),
  );
}





static TimeOfDay _convertToTimeOfDay(String timeString) {

    List<String> hourMinute = timeString.split(' ')[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    if (timeString.contains('PM') && hour != 12) {
      hour += 12;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }
}
