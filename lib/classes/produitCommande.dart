// ignore: file_names
import 'produit.dart';

class ProduitCommande {
  int id;
  Produit produit;
  String taille;
  int quantite;
  String details;

  ProduitCommande({
     required this.id,
    required this.produit,
    required this.taille,
    required this.quantite,
    required this.details
  });

  factory ProduitCommande.fromJson(Map<String, dynamic> json) {
  return ProduitCommande(
    id: json['id'],
    produit: Produit.fromJson(json['produit']),
    taille: json['taille'],
    quantite: json['quantite'],
    details: json['details']
  );
}
}
