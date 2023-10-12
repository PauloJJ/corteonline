class DaysAndHoursModel {
  late List seg;
  late List ter;
  late List qua;
  late List qui;
  late List sex;
  late List sab;
  late List dom;
  late String idEstablishment;

  DaysAndHoursModel({
    required this.seg,
    required this.ter,
    required this.qua,
    required this.qui,
    required this.sex,
    required this.sab,
    required this.dom,
    required this.idEstablishment,
  });

  DaysAndHoursModel.fromJson(Map<String, dynamic> json) {
    seg = json['seg'];
    ter = json['ter'];
    qua = json['qua'];
    qui = json['qui'];
    sex = json['sex'];
    sab = json['sab'];
    dom = json['dom'];
    idEstablishment = json['idEstablishment'];
  }
}
