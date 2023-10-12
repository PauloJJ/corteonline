import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nico/components/auth_or_app_component.dart';
import 'package:nico/model/list_date_time_model.dart';

class TutorialBarberComponent extends StatefulWidget {
  const TutorialBarberComponent({super.key});

  @override
  State<TutorialBarberComponent> createState() =>
      _TutorialBarberComponentState();
}

class _TutorialBarberComponentState extends State<TutorialBarberComponent> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = false;

  List<Map> listDays = [
    {'isSelect': true, 'day': 'Seg', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Ter', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Qua', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Qui', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Sex', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Sáb', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Dom', 'times': ListDateTimeModel().times},
  ];

  final List<Map> resetListDay = [
    {'isSelect': true, 'day': 'Seg', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Ter', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Qua', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Qui', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Sex', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Sáb', 'times': ListDateTimeModel().times},
    {'isSelect': false, 'day': 'Dom', 'times': ListDateTimeModel().times},
  ];

  List<String> listTimes = [];

  organizelistTime(List<String> listTimes) {
    setState(() {
      listTimes.sort(
        (a, b) {
          return int.tryParse(a.replaceAll(':', ''))!
              .compareTo(int.tryParse(b.replaceAll(':', ''))!.toInt());
        },
      );
    });
  }

  addNewTimer(List<String> listTimes) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 00),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (newTime != null) {
      // ignore: use_build_context_synchronously
      if (listTimes.contains(newTime.format(context)) == true) {
        // ignore: use_build_context_synchronously
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Aviso'),
              content: const Text('Este horário já foi definido'),
              actions: [
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
      } else {
        setState(() {
          listTimes.add(
            newTime.format(context),
          );
        });
      }
    }
  }

  int phases = 1;

  submitTimesAndDays() async {
    List<String> segList = [];
    List<String> terList = [];
    List<String> quaList = [];
    List<String> quinList = [];
    List<String> sexList = [];
    List<String> sabList = [];
    List<String> domList = [];

    for (var e in listDays) {
      if (e['times'].isEmpty) {
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Aviso'),
              content: const Text(
                  'Observação: Você não definiu horários para um dia da semana. Por favor, selecione os horários em que seu estabelecimento irá funcionar.'),
              actions: [
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

      setState(() {
        if (e['day'] == 'Seg') {
          segList.addAll(e['times']);
        }

        if (e['day'] == 'Ter') {
          terList.addAll(e['times']);
        }

        if (e['day'] == 'Qua') {
          quaList.addAll(e['times']);
        }

        if (e['day'] == 'Qui') {
          quinList.addAll(e['times']);
        }

        if (e['day'] == 'Sex') {
          sexList.addAll(e['times']);
        }

        if (e['day'] == 'Sáb') {
          sabList.addAll(e['times']);
        }

        if (e['day'] == 'Dom') {
          domList.addAll(e['times']);
        }
      });
    }

    setState(() {
      isLoading = true;
    });

    final isToChangeDays = await FirebaseFirestore.instance
        .collection('daysAndHours')
        .where('idEstablishment', isEqualTo: userId)
        .get();

    if (isToChangeDays.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('daysAndHours').doc().set({
        'seg': segList,
        'ter': terList,
        'qua': quaList,
        'qui': quinList,
        'sex': sexList,
        'sab': sabList,
        'dom': domList,
        'idEstablishment': userId,
      }).then((value) => (value) {
            setState(() {
              isLoading = false;
            });
          });
    } else {
      await FirebaseFirestore.instance
          .collection('daysAndHours')
          .doc(isToChangeDays.docs.first.id)
          .update({
        'seg': segList,
        'ter': terList,
        'qua': quaList,
        'qui': quinList,
        'sex': sexList,
        'sab': sabList,
        'dom': domList,
      }).then((value) => (value) {
                setState(() {
                  isLoading = false;
                });
              });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => AuthOrAppComponent(index: 0),
          ),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: phases == 1
          ? Column(
              children: [
                SizedBox(
                  height: size.height * 0.5,
                  width: size.width,
                  child: Lottie.asset(
                    'assets/json/dateselect.json',
                  ),
                ),
                Expanded(
                  child: Container(
                    color: color.primary,
                    width: size.width,
                    height: size.height * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Precisamos que você escolha os dias da semana e os horários disponíveis',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Para que seus clientes possam agendar os horários e datas desejadas.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                phases = 2;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 40),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : phases == 2
              ? Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppBar().preferredSize.height),
                      Text(
                        'Por favor, remova os dias em que seu estabelecimento não está disponível para atendimento',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Clique para remover os dias',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                        ),
                      ),
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 70,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listDays.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Card(
                            color: const Color.fromARGB(255, 201, 246, 255),
                            child: InkWell(
                              onTap: () {
                                if (listDays.length > 1) {
                                  setState(() {
                                    listDays.removeAt(index);
                                  });
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  listDays[index]['day'],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: color.primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          List<Map> newList = [];

                          setState(() {
                            newList.addAll(resetListDay);

                            listDays = newList;
                          });

                          print(resetListDay);
                        },
                        label: Text(
                          'Resetar dias',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                          ),
                        ),
                        icon: const Icon(
                          Icons.date_range,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: color.primary),
                          onPressed: () {
                            setState(() {
                              phases = 3;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 40,
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: size.height,
                  width: size.height,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBar(
                          leading: IconButton(
                            onPressed: () {
                              setState(() {
                                phases = 2;
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            'Por favor, escolha os horários disponíveis para cada dia da semana',
                            style: GoogleFonts.montserrat(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Days
                        Container(
                          height: size.height * 0.18,
                          alignment: Alignment.center,
                          child: ListView.builder(
                            itemCount: listDays.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    for (var e in listDays) {
                                      setState(() {
                                        if (e['isSelect'] == true) {
                                          e['isSelect'] = false;
                                        }

                                        listDays[index]['isSelect'] = true;
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: size.width * 0.15,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color:
                                            listDays[index]['isSelect'] == true
                                                ? color.primary
                                                : const Color.fromARGB(
                                                    255, 201, 246, 255),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 0.2,
                                            spreadRadius: 0.2,
                                            offset:
                                                Offset.fromDirection(0.50, 1),
                                            color: const Color.fromARGB(
                                                197, 136, 204, 218),
                                          ),
                                        ]),
                                    child: Text(
                                      listDays[index]['day'],
                                      style: GoogleFonts.montserrat(
                                        fontSize: 17,
                                        color:
                                            listDays[index]['isSelect'] == true
                                                ? Colors.white
                                                : color.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 15),

                        ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: listDays.length,
                          itemBuilder: (context, index) {
                            if (listDays[index]['isSelect'] == true) {
                              listTimes = listDays[index]['times'];
                              return Column(
                                children: [
                                  // Adicionar / Limpar tudo
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: SizedBox(
                                      width: size.width,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(height: 25),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton.icon(
                                                  onPressed: () async {
                                                    await addNewTimer(
                                                        listTimes);

                                                    organizelistTime(listTimes);
                                                  },
                                                  label: Text(
                                                    'Adicionar horário',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.access_alarm_rounded,
                                                    size: 25,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: TextButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      listTimes.clear();
                                                    });
                                                  },
                                                  label: Text(
                                                    'Limpar tudo',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons
                                                        .delete_forever_rounded,
                                                    size: 25,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Times
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: GridView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: listTimes.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 80,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        childAspectRatio: 1.5,
                                        mainAxisExtent: 40,
                                      ),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              listTimes.removeAt(index);
                                            });

                                            organizelistTime(listTimes);
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: (index % 2 == 0)
                                                  ? const Color.fromARGB(
                                                      255, 201, 246, 255)
                                                  : const Color.fromARGB(
                                                      255, 124, 218, 236),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                listTimes[index],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  if (listTimes.isEmpty)
                                    Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Icon(
                                          Icons.timer_sharp,
                                          size: 160,
                                          color: Colors.grey.shade300,
                                        ),
                                        const Text(
                                          'Selecione seus horários',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),

                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Container(
                            alignment: Alignment.center,
                            child: isLoading == true
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: color.primary),
                                    onPressed: () {
                                      submitTimesAndDays();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 40,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Finalizar',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward,
                                            size: 35,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
    );
  }
}
