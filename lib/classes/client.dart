import 'package:cafetariat/classes/produit.dart';

class Client {
  int id;
  String nom;
  String prenom;
  String courriel;
  String classe;
  int numero;
  double solde;
  String photo;
  List<Produit> favoris;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.courriel,
    required this.classe,
    required this.numero,
    required this.solde,
    required this.photo,
    required this.favoris,
  });

  // Méthode statique pour créer une instance de Client à partir d'un Map (JSON)
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      courriel: json['courriel'],
      classe: json['classe'],
      numero: json['numero'],
      solde: json['solde'].toDouble(),
      photo: json['photo'],
      favoris: List<Produit>.from(json['favoris'].map((favori) => Produit.fromJson(favori))),
    );
  }

  // Méthode pour convertir une instance de Client en Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'courriel': courriel,
      'classe': classe,
      'numero': numero,
      'solde': solde,
      'photo': photo,
      'favoris': favoris.map((favori) => favori.toJson()).toList(),
    };
  }
}


