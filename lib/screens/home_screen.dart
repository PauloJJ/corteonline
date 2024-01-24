import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:nico/components/appdrawer_component.dart';
import 'package:nico/components/auth_or_app_component.dart';
import 'package:nico/model/barber_model.dart';
import 'package:nico/model/days_and_hours_model.dart';
import 'package:nico/model/schedules_model.dart';
import 'package:nico/model/user_model.dart';
import 'package:nico/services/admob_service.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class HomeScreens extends StatefulWidget {
  final BarberModel? barberModel;

  const HomeScreens({super.key, required this.barberModel});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  ScrollController scrollController = ScrollController();

  final dateRangePickerController = DateRangePickerController();

  final userId = FirebaseAuth.instance.currentUser!.uid;

  int weekDay = DateTime.now().weekday;

  List<int> listDaysAvailable = [];

  List<Map<String, dynamic>> listSchedules = [];

  getSchedules({required String date}) async {
    listSchedules.clear();

    final docUser =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final docDayAndHours = await FirebaseFirestore.instance
        .collection('daysAndHours')
        .where('idEstablishment',
            isEqualTo: docUser['isClient'] == true
                ? docUser['establishmentId']
                : userId)
        .get();

    for (var e in docDayAndHours.docs) {
      for (var h in e[whatWeekDay(weekDay)]) {
        listSchedules.add({
          'hour': h,
          'isAvailable': true,
          'idUser': '',
          'idSchedules': '',
        });
      }
    }

    final doc = await FirebaseFirestore.instance
        .collection('schedules')
        .where('idEstablishment',
            isEqualTo: docUser['isClient'] == true
                ? docUser['establishmentId']
                : userId)
        .get();

    for (var e in doc.docs) {
      SchedulesModel schedulesModel = SchedulesModel.fromJson(e.data());

      String dateSchedule = DateFormat('dd/MM/yyyy')
          .format(schedulesModel.dateSchedules.toDate());

      if (dateSchedule == date) {
        for (var s in listSchedules) {
          if (s['hour'] == schedulesModel.hour) {
            s['isAvailable'] = false;
            s['userId'] = e['userId'];
            s['idSchedules'] = e.id;
          }
        }
      } else {}
    }

    setState(() {});
  }

  String whatWeekDay(int weekDay) {
    if (weekDay == 1) {
      return 'seg';
    } else if (weekDay == 2) {
      return 'ter';
    } else if (weekDay == 3) {
      return 'qua';
    } else if (weekDay == 4) {
      return 'qui';
    } else if (weekDay == 5) {
      return 'sex';
    } else if (weekDay == 6) {
      return 'sab';
    } else {
      return 'dom';
    }
  }

  addAvailableDays(DaysAndHoursModel daysAndHoursModel) async {
    // print(daysAndHoursModel.dom);

    if (daysAndHoursModel.seg.isEmpty && !listDaysAvailable.contains(1)) {
      listDaysAvailable.add(1);
    }
    if (daysAndHoursModel.ter.isEmpty && !listDaysAvailable.contains(2)) {
      listDaysAvailable.add(2);
    }
    if (daysAndHoursModel.qua.isEmpty && !listDaysAvailable.contains(3)) {
      listDaysAvailable.add(3);
    }
    if (daysAndHoursModel.qui.isEmpty && !listDaysAvailable.contains(4)) {
      listDaysAvailable.add(4);
    }
    if (daysAndHoursModel.sex.isEmpty && !listDaysAvailable.contains(5)) {
      listDaysAvailable.add(5);
    }
    if (daysAndHoursModel.sab.isEmpty && !listDaysAvailable.contains(6)) {
      listDaysAvailable.add(6);
    }
    if (daysAndHoursModel.dom.isEmpty && !listDaysAvailable.contains(7)) {
      listDaysAvailable.add(7);
    }
  }

  Widget sfDate({required String idEstablishment, required bool isClient}) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('daysAndHours')
          .where('idEstablishment', isEqualTo: idEstablishment)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DaysAndHoursModel daysAndHoursModel =
              DaysAndHoursModel.fromJson(snapshot.data!.docs.first.data());

          addAvailableDays(daysAndHoursModel);

          return SfDateRangePicker(
            headerStyle: DateRangePickerHeaderStyle(
              textStyle: GoogleFonts.montserrat(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            selectionColor: Colors.white,
            selectionTextStyle: GoogleFonts.montserrat(
              fontSize: 17,
              color: Colors.black,
            ),
            minDate: DateTime.now(),
            initialDisplayDate: DateTime.now(),
            initialSelectedDate: DateTime.now(),
            monthCellStyle: DateRangePickerMonthCellStyle(
              textStyle: GoogleFonts.montserrat(
                fontSize: 17,
                color: Colors.white,
              ),
              disabledDatesTextStyle: GoogleFonts.montserrat(
                fontSize: 17,
                color: Colors.grey,
              ),
              leadingDatesTextStyle: GoogleFonts.montserrat(
                fontSize: 17,
                color: Colors.white,
              ),
              blackoutDateTextStyle: GoogleFonts.montserrat(
                fontSize: 17,
                color: Colors.white,
              ),
              specialDatesTextStyle: GoogleFonts.montserrat(
                fontSize: 17,
                color: Colors.white,
              ),
              weekendTextStyle: GoogleFonts.montserrat(
                fontSize: 17,
                color: Colors.white,
              ),
              trailingDatesTextStyle: GoogleFonts.montserrat(
                fontSize: 17,
                color: Colors.white,
              ),
              todayTextStyle: GoogleFonts.montserrat(
                fontSize: 17,
                color: Colors.white,
              ),
              weekendDatesDecoration: BoxDecoration(
                color: const Color.fromARGB(132, 255, 29, 13),
                border: Border.all(color: Colors.red, width: 1),
                shape: BoxShape.circle,
              ),
            ),
            monthViewSettings: DateRangePickerMonthViewSettings(
              weekendDays: listDaysAvailable,
              viewHeaderStyle: DateRangePickerViewHeaderStyle(
                textStyle: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            view: DateRangePickerView.month,
            onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
              if (widget.barberModel == null) {
                isToDisplayInterstitial();
              }

              getSchedules(
                  date: DateFormat('dd/MM/yyyy')
                      .format(dateRangePickerController.selectedDate!));

              setState(() {
                weekDay = dateRangePickerController.selectedDate!.weekday;
              });

              FirebaseAnalytics.instance.logEvent(name: 'set_date_schedules');
            },
            controller: dateRangePickerController,
          );
        } else {
          return Container();
        }
      },
    );
  }

  setScheduleTime({
    required String hour,
    required DateTime dateSchedules,
    required String idEstablishment,
  }) async {
    String dateAndTime =
        '${DateFormat('dd/MM/yyyy').format(dateSchedules)} $hour';

    AdMobService().interstitialAdId();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tem certeza ?'),
          content: Text(
              'Que gostaria de fazer esse agendamento: ${DateFormat('dd/MM/yyyy').format(dateSchedules)} - ${hour}H'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final schedules = await FirebaseFirestore.instance
                    .collection('schedules')
                    .where('idEstablishment', isEqualTo: idEstablishment)
                    .get();

                for (var e in schedules.docs) {
                  String verification =
                      '${DateFormat('dd/MM/yyyy').format(e['dateSchedules'].toDate())} ${e['hour']}';

                  if (verification == dateAndTime) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          'Desculpe, ocorreu um problema. Por favor, tente novamente.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );

                    await getSchedules(
                      date: DateFormat('dd/MM/yyyy')
                          .format(dateRangePickerController.selectedDate!),
                    );

                    return Navigator.of(context).pop();
                  }
                }

                await FirebaseFirestore.instance
                    .collection('schedules')
                    .doc()
                    .set({
                  'dateOrder': DateTime.now(),
                  'dateSchedules': dateSchedules,
                  'hour': hour,
                  'userId': userId,
                  'idEstablishment': idEstablishment,
                }).then((value) async {
                  await FirebaseAnalytics.instance
                      .logEvent(name: 'made_an_appointment');

                  await getSchedules(
                    date: DateFormat('dd/MM/yyyy')
                        .format(dateRangePickerController.selectedDate!),
                  );

                  Provider.of<AdMobService>(context, listen: false)
                      .updateMadeAnAppointment();

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => AuthOrAppComponent(index: 1),
                      ),
                      (route) => false);
                });
              },
              child: Text(
                'Confirmar',
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  dataUserSchedule(
      {required UserModel userModel,
      required String hour,
      required String docId}) async {
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Informações do Cliente'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.document_scanner,
                    color: Color(0xFF156778),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: SelectableText(userModel.name)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Color(0xFF156778),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: SelectableText(userModel.cpf)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.email,
                    color: Color(0xFF156778),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      userModel.email,
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    color: Color(0xFF156778),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: SelectableText(
                    userModel.number,
                    style: TextStyle(color: Colors.blue.shade600),
                  )),
                ],
              ),
              const SizedBox(height: 15),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () async {
                  final url = WhatsAppUnilink(
                      phoneNumber: '+55 ${userModel.number}',
                      text:
                          'Olá, ${widget.barberModel!.name} aqui. Estou entrando em contato para confirmar o seu agendamento para o dia ${DateFormat('dd/MM/yyyy').format(dateRangePickerController.selectedDate!)} $hour. Está tudo certo?');

                  launchUrl(
                    Uri.parse(url.toString()),
                  );
                },
                child: Text(
                  'Enviar Mensagem \nno Whatsapp',
                  style: GoogleFonts.montserrat(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('schedules')
                    .doc(docId)
                    .delete()
                    .then((value) {
                  getSchedules(
                      date: DateFormat('dd/MM/yyyy')
                          .format(dateRangePickerController.selectedDate!));

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agendamento excluido'),
                    ),
                  );
                });
              },
              child: const Text(
                'Excluir Agendamento',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Voltar'),
            ),
          ],
        );
      },
    );
  }

  // Funções de ADS

  isToDisplayInterstitial() {
    int isToDisplay =
        Provider.of<AdMobService>(context, listen: false).getIsToDisplayHome();

    int showAdsScreenSchedule =
        Provider.of<AdMobService>(context, listen: false)
            .getShowAdsScreenHome();

    if (isToDisplay == showAdsScreenSchedule) {
      AdMobService().interstitialAdId();

      Provider.of<AdMobService>(context, listen: false)
          .updateShowAdsScreenHome();
    } else {
      Provider.of<AdMobService>(context, listen: false).updateisToDisplayHome();
    }
  }

  BannerAd? banner;

  createdBannerAd() async {
    // Android
    String? adUnitId;

    await AdMobService.bannerAdUnitId.then((value) {
      setState(() {
        adUnitId = value;
      });
    });

    banner = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: adUnitId!,
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('ad Loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    getSchedules(date: DateFormat('dd/MM/yyyy').format(DateTime.timestamp()));
    createdBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const AppdrawerComponent(),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          getSchedules(
            date: DateFormat('dd/MM/yyyy')
                .format(dateRangePickerController.selectedDate!),
          );

          setState(() {
            scrollController.animateTo(size.height * 0.5,
                duration: const Duration(seconds: 1), curve: Curves.linear);
          });
        },
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: SingleChildScrollView(
            controller: scrollController,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!['isClient'] == true) {
                    UserModel userModel =
                        UserModel.fromJson(snapshot.data!.data()!);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ADS - Banner
                        if (banner != null)
                          Container(
                            width: banner!.size.width.toDouble(),
                            height: banner!.size.height.toDouble(),
                            child: banner == null
                                ? Container()
                                : AdWidget(ad: banner!),
                          ),

                        // Selecionador de data
                        Container(
                          decoration: BoxDecoration(
                            color: color.primary,
                            image: const DecorationImage(
                              image: AssetImage('assets/images/barber.jpeg'),
                              fit: BoxFit.cover,
                              opacity: 0.2,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // select Date
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Container(
                                  child: sfDate(
                                    idEstablishment: userModel.establishmentId!,
                                    isClient: true,
                                  ),
                                ),
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 8,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Disponível',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 8,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Indisponíveis',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),

                        // Get Hours available
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Selecione o horário para seu agendamento',
                                style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: color.primary,
                                ),
                              ),
                              const SizedBox(height: 15),
                              listSchedules.isEmpty == true
                                  ? SizedBox(
                                      width: size.width,
                                      child: Center(
                                          child: Column(
                                        children: [
                                          const SizedBox(height: 25),
                                          Icon(
                                            Icons.timer_off_outlined,
                                            color: Colors.grey.shade200,
                                            size: 150,
                                          ),
                                          Text(
                                            'Horários indisponíveis',
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                            ),
                                          )
                                        ],
                                      )),
                                    )
                                  : GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 80,
                                        crossAxisSpacing: 15,
                                        mainAxisSpacing: 15,
                                        mainAxisExtent: 35,
                                      ),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: listSchedules.length,
                                      itemBuilder: (context, index) {
                                        String hours =
                                            listSchedules[index]['hour'];

                                        bool isAvailable =
                                            listSchedules[index]['isAvailable'];

                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(800),
                                          onTap: isAvailable == false
                                              ? null
                                              : () {
                                                  int hour = int.parse(
                                                    hours.length == 4
                                                        ? hours[0]
                                                        : hours
                                                            .replaceAll(
                                                                ':', '.')
                                                            .replaceRange(
                                                                2, null, ''),
                                                  );

                                                  int minutes = int.parse(
                                                    hours.length == 4
                                                        ? hours
                                                            .replaceAll(':', '')
                                                            .substring(1)
                                                        : hours
                                                            .replaceAll(':', '')
                                                            .substring(2),
                                                  );

                                                  setScheduleTime(
                                                    hour: hours,
                                                    dateSchedules: DateTime(
                                                      dateRangePickerController
                                                          .selectedDate!.year,
                                                      dateRangePickerController
                                                          .selectedDate!.month,
                                                      dateRangePickerController
                                                          .selectedDate!.day,
                                                    ).add(
                                                      Duration(
                                                        minutes: minutes,
                                                        hours: hour,
                                                      ),
                                                    ),
                                                    // dateRangePickerController
                                                    //     .selectedDate.!,
                                                    idEstablishment: userModel
                                                        .establishmentId!,
                                                  );
                                                },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isAvailable == false
                                                  ? color.primary
                                                  : const Color.fromARGB(
                                                      255, 154, 238, 255),
                                              borderRadius:
                                                  BorderRadius.circular(800),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              hours,
                                              style: TextStyle(
                                                color: isAvailable == false
                                                    ? Colors.white
                                                    : color.primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        )
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ADS - Banner
                        if (banner != null)
                          SizedBox(
                            width: 468,
                            height: 60,
                            child: Center(
                              child: banner == null
                                  ? Container()
                                  : AdWidget(ad: banner!),
                            ),
                          ),

                        // Selecionador de data
                        Container(
                          decoration: BoxDecoration(
                            color: color.primary,
                            image: const DecorationImage(
                              image: AssetImage('assets/images/barber.jpeg'),
                              fit: BoxFit.cover,
                              opacity: 0.2,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // select Date
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Container(
                                  child: sfDate(
                                      idEstablishment: userId, isClient: false),
                                ),
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 8,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Disponível',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 8,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Indisponíveis',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),

                        // Get Hours available
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Sua Agenda de Trabalho',
                                style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: color.primary,
                                ),
                              ),
                              const SizedBox(height: 25),
                              listSchedules.isEmpty == true
                                  ? SizedBox(
                                      width: size.width,
                                      child: Center(
                                          child: Column(
                                        children: [
                                          const SizedBox(height: 25),
                                          Icon(
                                            Icons.timer_off_outlined,
                                            color: Colors.grey.shade200,
                                            size: 150,
                                          ),
                                          Text(
                                            'Horários indisponíveis',
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                            ),
                                          )
                                        ],
                                      )),
                                    )
                                  : GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 110,
                                        mainAxisExtent: 100,
                                        crossAxisSpacing: 15,
                                        mainAxisSpacing: 15,
                                      ),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: listSchedules.length,
                                      itemBuilder: (context, index) {
                                        String hours =
                                            listSchedules[index]['hour'];

                                        bool isAvailable =
                                            listSchedules[index]['isAvailable'];

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: isAvailable == false
                                                ? color.primary
                                                : const Color.fromARGB(
                                                    255, 154, 238, 255),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${hours}H',
                                                  style: TextStyle(
                                                      color:
                                                          isAvailable == false
                                                              ? Colors.white
                                                              : color.primary,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                                if (listSchedules[index]
                                                        ['isAvailable'] ==
                                                    false)
                                                  FutureBuilder(
                                                    future: FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(
                                                            listSchedules[index]
                                                                ['userId'])
                                                        .get(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        UserModel userModel =
                                                            UserModel.fromJson(
                                                                snapshot.data!
                                                                    .data()!);

                                                        return InkWell(
                                                          onTap: () {
                                                            dataUserSchedule(
                                                              userModel:
                                                                  userModel,
                                                              hour: hours,
                                                              docId: listSchedules[
                                                                      index][
                                                                  'idSchedules'],
                                                            );
                                                          },
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              CircleAvatar(
                                                                backgroundColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        32,
                                                                        158,
                                                                        184),
                                                                radius: 18,
                                                                child: Text(
                                                                  userModel.name
                                                                      .replaceRange(
                                                                          1,
                                                                          null,
                                                                          ''),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        25,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        return Container();
                                                      }
                                                    },
                                                  )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                } else {
                  return SizedBox(
                    height: size.height,
                    width: size.width,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
