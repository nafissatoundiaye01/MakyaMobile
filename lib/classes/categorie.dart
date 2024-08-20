class Categorie {
  int id;
  String nom;
  String photo;

  Categorie({required this.id, required this.nom, required this.photo});


  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'],
      nom: json['nom'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'photo': photo,
    };
  }
}
