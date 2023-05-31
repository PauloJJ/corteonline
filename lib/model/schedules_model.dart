class SchedulesModel {
  String? idUser;
  String? time;
  bool? wasScheduled;
  int? row;

  SchedulesModel({
    this.idUser,
    this.time,
    this.wasScheduled,
    this.row,
  });

  SchedulesModel.fromJson(Map<String, dynamic>? json) {
    idUser = json!['idUser'];
    time = json['time'];
    wasScheduled = json['wasScheduled'];
    row = json['row'];
  }
}
