class BarberModel {
  late String name;
  late String cpf;
  late String email;
  late String number;
  late String imageProfile;
  late bool banned;
  late bool isClient;

  BarberModel({
    required this.email,
    required this.cpf,
    required this.name,
    required this.number,
    required this.imageProfile,
    required this.banned,
    required this.isClient,
  });

  BarberModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    cpf = json['cpf'];
    email = json['email'];
    number = json['number'];
    imageProfile = json['imageProfile'];
    banned = json['banned'];
    isClient = json['isClient'];
  }
}
