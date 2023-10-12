class UserModel {
  late String name;
  late String cpf;
  late String email;
  late String number;
  late String? establishmentId;
  late bool banned;
  late bool isClient;

  UserModel({
    required this.email,
    required this.cpf,
    required this.name,
    required this.number,
    required this.banned,
    required this.isClient,
    this.establishmentId,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    cpf = json['cpf'];
    email = json['email'];
    number = json['number'];
    banned = json['banned'];
    isClient = json['isClient'];
    establishmentId = json['establishmentId'];
  }
}
