import 'package:cloud_firestore/cloud_firestore.dart';

class SchedulesModel {
  late Timestamp dateOrder;
  late Timestamp dateSchedules;
  late String hour;
  late String idEstablishment;
  late String userId;

  SchedulesModel({
    required this.dateOrder,
    required this.dateSchedules,
    required this.hour,
    required this.idEstablishment,
    required this.userId,
  });

  SchedulesModel.fromJson(Map<String, dynamic> json) {
    dateOrder = json['dateOrder'];
    dateSchedules = json['dateSchedules'];
    hour = json['hour'];
    idEstablishment = json['idEstablishment'];
    userId = json['userId'];
  }
}
