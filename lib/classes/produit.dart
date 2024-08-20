class Produit {
  int id;
  String nom;
  List<String> formats;
  List<double> prixParFormat;
  List<int> nombresDispoParFormat;
  String categorie;
  String photo;
  String description;

  Produit({
    required this.id,
    required this.nom,
    required this.formats,
    required this.prixParFormat,
    required this.nombresDispoParFormat,
    required this.categorie,
    required this.photo,
    required this.description
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
  return Produit(
    id: json['id'],
    categorie: json['categorie'],
    description: json['description'],
    formats: List<String>.from(json['formats']),
    nom: json['nom'],
    nombresDispoParFormat: List<int>.from(json['nombresDispoParFormat']),
    photo: json['photo'],
    prixParFormat: List<double>.from(json['prixParFormat']),
  );
}


  toJson() {}
}
