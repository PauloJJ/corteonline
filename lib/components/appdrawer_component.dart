import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nico/components/tutorial_barber_component.dart';
import 'package:nico/components/tutorial_client_component.dart';
import 'package:nico/model/barber_model.dart';
import 'package:nico/model/user_model.dart';
import 'package:nico/screens/delete_account.dart';
import 'package:nico/screens/settings_screen.dart';

class AppdrawerComponent extends StatefulWidget {
  const AppdrawerComponent({super.key});

  @override
  State<AppdrawerComponent> createState() => _AppdrawerComponentState();
}

class _AppdrawerComponentState extends State<AppdrawerComponent> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  logout() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tem certeza que deseja sair ?'),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut().then(
                      (value) => Navigator.of(context).pop(),
                    );
              },
              child: const Text('Sim'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: const Text('Não'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Drawer(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 15),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!['isClient'] == true) {
                  final userModel = UserModel.fromJson(snapshot.data!.data()!);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seus dados',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Nome
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 20,
                            color: color.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            userModel.name,
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Cpf
                      Row(
                        children: [
                          Icon(
                            Icons.document_scanner,
                            size: 20,
                            color: color.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            userModel.cpf,
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Email
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 20,
                            color: color.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            userModel.email,
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Numero
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 20,
                            color: color.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            userModel.number,
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(
                                userModel: userModel,
                                isClient: userModel.isClient,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.settings_sharp,
                              size: 25,
                              color: color.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Modificar',
                              style: GoogleFonts.montserrat(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: color.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(
                        height: 50,
                        color: Colors.grey.shade300,
                      ),

                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userModel.establishmentId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            BarberModel barberModel =
                                BarberModel.fromJson(snapshot.data!.data()!);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estabelecimento Selecionado',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        barberModel.imageProfile,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            barberModel.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          SelectableText(
                                            barberModel.number,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            barberModel.email,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),

                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const TutorialClientComponent(phase: 2),
                          ));
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: Icon(
                          Icons.add_home_work_rounded,
                          color: color.primary,
                        ),
                        title: const Text(
                          'Alterar Estabelecimento',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Divider(
                        height: 50,
                        color: Colors.grey.shade300,
                      ),

                      ListTile(
                        onTap: () {
                          logout();
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: Icon(
                          Icons.exit_to_app_outlined,
                          color: color.primary,
                        ),
                        title: const Text(
                          'Sair',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const DeleteAccount(),
                          ));
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Excluir conta',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                } else {
                  BarberModel barberModel =
                      BarberModel.fromJson(snapshot.data!.data()!);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seus dados',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Nome
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 20,
                            color: color.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            barberModel.name,
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Cpf
                      Row(
                        children: [
                          Icon(
                            Icons.document_scanner,
                            size: 20,
                            color: color.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            barberModel.cpf,
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Email
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 20,
                            color: color.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            barberModel.email,
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Numero
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 20,
                            color: color.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            barberModel.number,
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                        ],
                      ),

                      Divider(
                        height: 50,
                        color: Colors.grey.shade300,
                      ),

                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TutorialBarberComponent(),
                          ));
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: Icon(
                          Icons.timer_outlined,
                          color: color.primary,
                        ),
                        title: const Text(
                          'Alterar Dias e Horarios Disponíveis',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      ListTile(
                        onTap: () {
                          logout();
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: Icon(
                          Icons.exit_to_app_outlined,
                          color: color.primary,
                        ),
                        title: const Text(
                          'Sair',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const DeleteAccount(),
                          ));
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Excluir conta',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
