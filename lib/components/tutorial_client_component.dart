import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nico/components/auth_or_app_component.dart';
import 'package:nico/model/barber_model.dart';

class TutorialClientComponent extends StatefulWidget {
  final int? phase;

  const TutorialClientComponent({super.key, this.phase});

  @override
  State<TutorialClientComponent> createState() =>
      _TutorialClientComponentState();
}

class _TutorialClientComponentState extends State<TutorialClientComponent> {
  final seacrhController = TextEditingController();

  int phase = 1;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> listDuplicateEstablishment =
      [];

  List<QueryDocumentSnapshot<Map<String, dynamic>>> listEstablishment = [];

  bool isAnimated = false;
  bool isLoading = true;

  final userId = FirebaseAuth.instance.currentUser!.uid;

  timerAnimated() {
    Timer(Duration(microseconds: 200), () {
      setState(() {
        isAnimated = true;
      });
    });
  }

  getEstablishment() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .where('isClient', isEqualTo: false)
        .get();

    final docDaysAndHours =
        await FirebaseFirestore.instance.collection('daysAndHours').get();

    for (var e in docDaysAndHours.docs) {
      for (var d in doc.docs) {
        if (e['idEstablishment'] == d.id) {
          setState(() {
            listDuplicateEstablishment.add(d);

            listEstablishment = listDuplicateEstablishment;
          });
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  seachEstablishment(String seach) {
    setState(() {
      listEstablishment = listDuplicateEstablishment
          .where((element) => element['name']
              .toString()
              .toLowerCase()
              .contains(seach.toLowerCase()))
          .toList();
    });
  }

  selectEstablishment(
      {required BarberModel barberModel, required String docId}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Perfeito!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Ótima escolha! Você selecionou o estabelecimento',
                      style: GoogleFonts.montserrat(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' ${barberModel.name} ',
                      style: GoogleFonts.montserrat(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'para fazer seus agendamentos! \n\nOBS: Saiba que cada estabelecimento tem sua maneira única de trabalhar. No nosso app, você encontrará salões de beleza e barbearias que se adequam às suas preferências!',
                      style: GoogleFonts.montserrat(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({'establishmentId': docId}).then(
                    (value) => Navigator.of(context)
                      ..pop()
                      ..pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => AuthOrAppComponent(index: 0),
                        ),
                        (route) => false,
                      ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CONTINUAR ',
                        style: GoogleFonts.montserrat(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getEstablishment();

    if (widget.phase != null) {
      phase = widget.phase!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: widget.phase != null
          ? AppBar(
              title: const Text(
                'Estabelecimentos',
                style: TextStyle(color: Colors.black),
              ),
            )
          : null,
      body: phase == 1
          ? Column(
              children: [
                SizedBox(
                  height: size.height * 0.5,
                  width: size.width,
                  child: Lottie.asset(
                    'assets/json/search.json',
                    fit: BoxFit.contain,
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
                            'Vamos escolher um Salão ou Barbearia para você?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Antes de fazer o agendamento, precisamos que você escolha o salão de beleza ou barbearia que frequenta',
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
                                phase = 2;
                              });

                              timerAnimated();
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: isLoading == true
                    ? SizedBox(
                        height: size.height,
                        width: size.width,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(height: size.height * 0.05),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300,
                            ),
                            child: TextFormField(
                              controller: seacrhController,
                              onChanged: (value) {
                                seachEstablishment(value);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Pesquisar pelo nome',
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 30,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          ListView.builder(
                            itemCount: listEstablishment.length,
                            padding: const EdgeInsets.all(0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              BarberModel barberModel = BarberModel.fromJson(
                                  listEstablishment[index].data());

                              String docId = listEstablishment[index].id;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 0),
                                child: InkWell(
                                  onTap: () {
                                    selectEstablishment(
                                        barberModel: barberModel, docId: docId);
                                  },
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  barberModel.imageProfile,
                                                ),
                                                radius: 25,
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    barberModel.name,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.phone,
                                                        color: Colors
                                                            .grey.shade600,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        barberModel.number,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.email,
                                                        color: Colors
                                                            .grey.shade600,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      SizedBox(
                                                        width: size.width * 0.5,
                                                        child: FittedBox(
                                                          child: Text(
                                                            barberModel.email,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ),
            ),
    );
  }
}
