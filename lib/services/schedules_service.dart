import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulesService extends ChangeNotifier {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  List<DocumentSnapshot<Map<String, dynamic>>> _listSchedules = [];

  List<DocumentSnapshot<Map<String, dynamic>>> getListSchedules() {
    return _listSchedules;
  }

  getSchedules() async {
    List<DocumentSnapshot<Map<String, dynamic>>> listSchedules = [];

    final schedules = await FirebaseFirestore.instance
        .collection('schedules')
        .where('userId', isEqualTo: userId)
        .get();

    for (var e in schedules.docs) {
      listSchedules.add(e);
    }

    listSchedules.sort(
      (a, b) {
        Timestamp dateA = a['dateSchedules'];
        Timestamp dateb = b['dateSchedules'];

        // print(int.parse(a['hour'].toString().replaceRange(3, null, '')));

        return dateA.compareTo(dateb);
      },
    );

    _listSchedules = listSchedules;

    notifyListeners();
  }

  deleteSchedulingsAutomatic() async {
    DateTime date = Timestamp.now().toDate();

    final schedules =
        await FirebaseFirestore.instance.collection('schedules').get();

    for (var e in schedules.docs) {
      Timestamp dateSchedules = e['dateSchedules'];

      String dateScheduleString =
          DateFormat('dd/MM/yyyy').format(dateSchedules.toDate());

      String dateNowString = DateFormat('dd/MM/yyyy').format(date);

      if (date.compareTo(e['dateSchedules'].toDate()) == 1 &&
          dateScheduleString != dateNowString) {
        await FirebaseFirestore.instance
            .collection('schedules')
            .doc(e.id)
            .delete();
      }
    }
  }
}
