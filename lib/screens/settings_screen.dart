import 'dart:io';
import 'dart:math';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nico/components/tutorial_client_component.dart';
import 'package:nico/model/user_model.dart';

import '../model/barber_model.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel? userModel;
  final bool isClient;

  const SettingsScreen({
    super.key,
    required this.userModel,
    required this.isClient,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final emailController = TextEditingController();

  final userId = FirebaseAuth.instance.currentUser!.uid;

  String name = '';
  String number = '';
  String image = '';

  bool isLoading = false;

  updateControllers() async {
    final dataUser =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (dataUser['isClient'] == true) {
      name = dataUser['name'];
      number = dataUser['number'];

      nameController.text = dataUser['name'];
      numberController.text = dataUser['number'];
    } else {
      name = dataUser['name'];
      number = dataUser['number'];
      image = dataUser['imageProfile'];

      nameController.text = dataUser['name'];
      numberController.text = dataUser['number'];
      emailController.text = dataUser['email'];
    }

    setState(() {});
  }

  selectImage() async {
    XFile? imagePick = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );

    if (imagePick != null) {
      setState(() {
        isLoading = true;
      });

      String path = 'imagesProfile/${Random().nextDouble()}';

      final ref = FirebaseStorage.instance.ref().child(path);

      await ref.putFile(File(imagePick.path));

      String url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'imageProfile': url});

      updateControllers();

      setState(() {
        isLoading = false;
      });
    }
  }

  updateDatasUser() async {
    if (nameController.text.isEmpty) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Alerta'),
            content: const Text('O campo Nome não pode ser deixado em branco'),
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

    if (numberController.text.length < 14) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Alerta'),
            content: const Text('Número inválido'),
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

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'name': nameController.text,
      'number': numberController.text,
    }).then((value) {
      updateControllers();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Modificação Feita com Sucesso'),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    updateControllers();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          nameController.text != name || numberController.text != number
              ? FloatingActionButton.extended(
                  onPressed: () {
                    updateDatasUser();
                  },
                  extendedPadding: const EdgeInsets.all(40),
                  label: Text(
                    'Atualizar',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                    ),
                  ),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(500),
                    borderSide: BorderSide.none,
                  ),
                )
              : null,
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SizedBox(
          height: size.height,
          width: size.width,
          child: widget.isClient == true
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Perfil',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: nameController,
                          onChanged: (value) {
                            setState(() {
                              nameController;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            label: const Text(
                              'Nome',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            label: Text(
                              widget.userModel!.cpf,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            label: Text(
                              widget.userModel!.email,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: numberController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              numberController;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            label: const Text(
                              'Número',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey.shade300, height: 60),
                        const Text(
                          'Estabelecimento Selecionado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 15),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userModel!.establishmentId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              BarberModel barberModel =
                                  BarberModel.fromJson(snapshot.data!.data()!);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  ListTile(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            const TutorialClientComponent(
                                                phase: 2),
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
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 65,
                                child: CircleAvatar(
                                  backgroundImage: image.isEmpty
                                      ? null
                                      : NetworkImage(image),
                                  radius: 62,
                                ),
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: isLoading == true
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          selectImage();
                                        },
                                        icon: Icon(
                                          Icons.photo_camera,
                                          color: color.primary,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: nameController,
                          onChanged: (value) {
                            setState(() {
                              nameController;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            label: const Text(
                              'Nome',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            label: Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            label: Text(
                              emailController.text,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: numberController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              numberController;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            label: const Text(
                              'Número',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
    );
  }
}
