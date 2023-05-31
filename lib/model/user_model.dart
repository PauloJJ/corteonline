class UserModel {
  late String name;
  late String email;
  late String number;
  late String imageProfile;
  late bool banned;

  UserModel({
    required this.email,
    required this.name,
    required this.number,
    required this.imageProfile,
    required this.banned,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    number = json['number'];
    imageProfile = json['imageProfile'];
    banned = json['banned'];
  }
}
