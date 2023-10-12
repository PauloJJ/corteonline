// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nico/components/appdrawer_component.dart';
import 'package:nico/model/schedules_model.dart';
import 'package:nico/model/user_model.dart';
import 'package:nico/services/admob_service.dart';
import 'package:nico/services/schedules_service.dart';
import 'package:provider/provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  List<bool> isDeleteLoading = [];
  String dateNow = DateFormat('dd/MM/yyyy').format(Timestamp.now().toDate());

  UserModel? userModel;

  getUserOn() async {
    final userOn =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userOn['isClient'] == true) {
      userModel = UserModel.fromJson(userOn.data()!);
    }
  }

  // função para deletar agendamento no firebase
  deleteScheduling({
    required String docId,
    required bool isDeleteLoading,
    required String date,
    required String hour,
  }) async {
    setState(() {
      isDeleteLoading = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tem certeza ?'),
        content: Text('Que gostaria de deletar o agendamento $date ${hour}H'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('schedules')
                  .doc(docId)
                  .delete()
                  .then((value) {
                Provider.of<SchedulesService>(context, listen: false)
                    .getSchedules();

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Agendamento excluido'),
                  ),
                );
              });
            },
            child: const Text('Sim'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Não'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timings) async {
      await Provider.of<SchedulesService>(context, listen: false)
          .deleteSchedulingsAutomatic();

      bool madeAnAppointment = Provider.of<AdMobService>(context, listen: false)
          .getMadeAnAppointment();

      Provider.of<SchedulesService>(context, listen: false).getSchedules();

      if (madeAnAppointment == false) {
        int isToDisplay =
            Provider.of<AdMobService>(context, listen: false).getIsToDisplay();
        int showAdsScreenSchedule =
            Provider.of<AdMobService>(context, listen: false)
                .getShowAdsScreenSchedule();

        if (isToDisplay == showAdsScreenSchedule) {
          AdMobService().interstitialAdId();

          Provider.of<AdMobService>(context, listen: false)
              .updateShowAdsScreenSchedule();
        } else {
          Provider.of<AdMobService>(context, listen: false).updateisToDisplay();
        }
      } else {
        Provider.of<AdMobService>(context, listen: false)
            .updateMadeAnAppointment();
      }
    });

    getUserOn();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final listSchedules =
        Provider.of<SchedulesService>(context).getListSchedules();

    return Scaffold(
      drawer: const AppdrawerComponent(),
      appBar: AppBar(
        title: const Text(
          'Agendamentos',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.help_outline_outlined,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const WidgetSpan(
                        child: SizedBox(
                          width: 3,
                        ),
                      ),
                      TextSpan(
                        text:
                            'Se você não puder comparecer ao local na data e horário marcados, por favor, cancele o seu agendamento. Lembre-se de que, ao agendar e não comparecer, você poderá ser sujeito a medidas que incluem a exclusão da nossa plataforma',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 40,
                  color: Colors.grey.shade100,
                ),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 6,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Dia do agendamento',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: color.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ListView.builder(
                  itemCount: listSchedules.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    SchedulesModel schedulesModel =
                        SchedulesModel.fromJson(listSchedules[index].data()!);

                    isDeleteLoading.add(false);

                    String dateSchedules = DateFormat('dd/MM/yyyy')
                        .format(schedulesModel.dateSchedules.toDate());

                    // print(dateSchedules);

                    return userModel != null &&
                            userModel!.establishmentId! !=
                                schedulesModel.idEstablishment
                        ? Container()
                        : Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                deleteScheduling(
                                  docId: listSchedules[index].id,
                                  isDeleteLoading: isDeleteLoading[index],
                                  date: DateFormat('dd/MM/yyyy').format(
                                      schedulesModel.dateSchedules.toDate()),
                                  hour: schedulesModel.hour,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.date_range,
                                          size: 27,
                                          color: color.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(
                                              schedulesModel.dateSchedules
                                                  .toDate()),
                                          style: GoogleFonts.montserrat(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: color.primary,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (dateSchedules == dateNow)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Text(
                                                'HOJE',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer_sharp,
                                          size: 27,
                                          color: color.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Horário ${schedulesModel.hour}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 17,
                                            fontWeight: FontWeight.normal,
                                            color: color.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                  },
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
