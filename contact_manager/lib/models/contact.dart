class Contact {
  int? id;
  String name;
  String phone;
  String email;
  String address;
  String notes;
  String? photo;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.notes,
    this.photo,
  });

  // Convertir un contact en Map (pour SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'photo': photo,
    };
  }

  // Créer un contact depuis un Map (quand on lit la BD)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      notes: map['notes'],
      photo: map['photo'],
    );
  }
}
