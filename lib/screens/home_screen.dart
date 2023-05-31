import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nico/components/auth_or_app_component.dart';
import 'package:nico/model/list_date_time_model.dart';
import 'package:nico/model/schedules_model.dart';
import 'package:nico/model/user_model.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class HomeScreens extends StatefulWidget {
  UserModel userModel;

  HomeScreens({required this.userModel});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  DateTime dateTime = DateTime.now();
  String dateTimeNowString = '';

  List<Map<String, dynamic>> listTimes = [];
  List schedulesAuto = [];

  List<bool> isDeleteLoading = [];

  getTimes() async {
    setState(() {
      listTimes.clear();
      isDeleteLoading.clear();
    });

    DateTime dateNow = DateTime.now();

    DateTime removeHourDate =
        DateTime(dateNow.year, dateNow.month, dateNow.day);

    print('remove hour $removeHourDate');

    final times = await FirebaseFirestore.instance
        .collection('times')
        .orderBy('row')
        .get();

    final getScheduling =
        await FirebaseFirestore.instance.collection('scheduling').get();

    for (var e in times.docs) {
      listTimes.add({'doc': e, 'isAvailable': true, 'docScheduling': null});
    }

    for (var e in getScheduling.docs) {
      DateTime dateDoc = DateTime.parse(e['date']);

      if (dateDoc.compareTo(removeHourDate) < 0) {
        await FirebaseFirestore.instance
            .collection('scheduling')
            .doc(e.id)
            .delete();
      } else if (dateTimeNowString == e['date']) {
        listTimes.forEach((element) {
          if (element['doc']['time'] == e['time']) {
            element.update('isAvailable', (value) => false);
            element.update('docScheduling', (value) => e);
          }
        });
      } else {
        print('não');
      }
    }

    setState(() {});
  }

  toCreate() async {
    for (var e in ListDateTimeModel().times) {
      await FirebaseFirestore.instance.collection('times').doc(e['time']).set(
          {'time': e['time'], 'row': e['row'], 'schedules': e['schedules']});
    }
  }

  selectTime(String time, String idTime) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agendar corte para ${time}H'),
        content: const Text(
            'Você tem certeza de que gostaria de agendar seu corte para este horário? Por favor, lembre-se de que se você não comparecer no horário agendado, poderá perder sua reserva.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Voltar',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // convertando data

              var formatter = DateFormat('yyyy-MM-dd');
              String formattedDate = formatter.format(dateTime);
              print(formattedDate);

              await FirebaseFirestore.instance
                  .collection('scheduling')
                  .doc()
                  .set({
                'idUser': userId,
                'date': formattedDate,
                'time': time
              }).then((value) {
                Navigator.of(context).pop();

                getTimes();

                return ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Agendamento marcado para ${time}H'),
                  ),
                );
              });
            },
            child: const Text(
              'Sim',
              style: TextStyle(
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sfDate() {
    return SfDateRangePicker(
      headerStyle: DateRangePickerHeaderStyle(
        textStyle: GoogleFonts.montserrat(
            fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
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
          color: Colors.grey.shade700,
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
          color: const Color.fromARGB(61, 244, 67, 54),
          border: Border.all(color: Colors.red, width: 1),
          shape: BoxShape.circle,
        ),
      ),
      monthViewSettings: DateRangePickerMonthViewSettings(
        weekendDays: [7],
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
        setState(() {
          dateTime = dateRangePickerSelectionChangedArgs.value!;
          dateTimeNowString = DateFormat('yyyy-MM-dd')
              .format(dateRangePickerSelectionChangedArgs.value!);
        });

        getTimes();

        print(dateTime);
      },
    );
  }

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
                  .collection('scheduling')
                  .doc(docId)
                  .delete()
                  .then((value) {
                getTimes();
                Navigator.of(context).pop();
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
    getTimes();

    setState(() {
      dateTimeNowString = DateFormat('yyyy-MM-dd').format(dateTime);
    });

    print('Data de hoje $dateTimeNowString');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primary,
        title: Text(
          widget.userModel.name,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              widget.userModel.imageProfile,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut().then(
                    (value) => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const AuthOrAppComponent(),
                      ),
                      (route) => false,
                    ),
                  );
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'Faça seu agendamento',
                        style: GoogleFonts.montserrat(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        child: sfDate(),
                      ),
                    ),


               

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: const [
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
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('scheduling')
                          .where('idUser', isEqualTo: userId)
                          .orderBy('date')
                          .orderBy('time')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!.docs.isEmpty
                              ? Container()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                        color: Colors.white, height: 20),
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Text(
                                        'Seus Agendamentos',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      itemCount: snapshot.data!.docs.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        String date =
                                            '${snapshot.data!.docs[index]['date'].toString().substring(8)}/${snapshot.data!.docs[index]['date'].toString().substring(5, 7)}/${snapshot.data!.docs[index]['date'].toString().substring(0, 4)}';

                                        isDeleteLoading.add(false);

                                        String docId =
                                            snapshot.data!.docs[index].id;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 8),
                                          child: Card(
                                            color: Colors.black26,
                                            child: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.date_range,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        date,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          fontSize: 18,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      isDeleteLoading[index] ==
                                                              true
                                                          ? const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )
                                                          : IconButton(
                                                              onPressed:
                                                                  () async {
                                                                deleteScheduling(
                                                                  docId: docId,
                                                                  isDeleteLoading:
                                                                      isDeleteLoading[
                                                                          index],
                                                                  date: date,
                                                                  hour: snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index]['time'],
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .delete_forever_outlined,
                                                                size: 28,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.timer_sharp,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Horário ${snapshot.data!.docs[index]['time']}',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          fontSize: 18,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.normal,
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
                                );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: listTimes.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // toCreate();
                          //     print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'.length);
                          //   },
                          //   child: const Text('data'),
                          // ),

                          const SizedBox(height: 30),

                          Text(
                            'Horários disponíveis',
                            style: GoogleFonts.montserrat(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          // Text(
                          //   'Os horários são redefinidos \ndiariamente às 22h.',
                          //   style: GoogleFonts.montserrat(
                          //     fontSize: 17,
                          //     fontWeight: FontWeight.w400,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                          const SizedBox(height: 15),

                          ListView.builder(
                            itemCount: listTimes.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              SchedulesModel schedulesModel =
                                  SchedulesModel.fromJson(
                                listTimes[index]['doc'].data(),
                              );

                              bool isAvailable =
                                  listTimes[index]['isAvailable'];

                              // String dates = schedulesAuto[index]['date']

                              var scheduling =
                                  listTimes[index]['docScheduling'];

                              final idTime = listTimes[index]['doc'].id;

                              return InkWell(
                                onTap: isAvailable == false
                                    ? null
                                    : () {
                                        selectTime(
                                            schedulesModel.time!, idTime);
                                      },
                                child: Card(
                                  color: isAvailable == false
                                      ? color.primary
                                      : null,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ElevatedButton(
                                        //   onPressed: () {
                                        //     // print(schedulesAuto.contains('2023-05-28'));

                                        //     // schedulesModel.schedules!.forEach((element) {
                                        //     //   print(element['date']);
                                        //     // });
                                        //   },
                                        //   child: Text('data'),
                                        // ),
                                        Text(
                                          '${schedulesModel.time!}H',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: isAvailable == false
                                                ? Colors.white
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          isAvailable == false
                                              ? 'Indisponível'
                                              : 'Disponível',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 17,
                                            color: isAvailable == false
                                                ? color.error
                                                : null,
                                          ),
                                        ),

                                        if (isAvailable == false)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Divider(
                                                  color: Colors.white),
                                              StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(scheduling['idUser'])
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    UserModel userModel =
                                                        UserModel.fromJson(
                                                            snapshot.data!
                                                                .data()!);

                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                userModel
                                                                    .imageProfile,
                                                              ),
                                                              radius: 30,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              userModel.name
                                                                          .length >
                                                                      18
                                                                  ? userModel
                                                                      .name
                                                                      .replaceRange(
                                                                      18,
                                                                      null,
                                                                      '.',
                                                                    )
                                                                  : userModel
                                                                      .name,
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  } else {
                                                    return Container();
                                                  }
                                                },
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
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
