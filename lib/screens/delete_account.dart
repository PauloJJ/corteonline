// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final passwordController = TextEditingController();

  bool isLoading = false;

  deleteAccount() async {
    String email = FirebaseAuth.instance.currentUser!.email!;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email, password: passwordController.text)
          .then((value) async {
        await FirebaseAuth.instance.currentUser!.delete();

        setState(() {
          isLoading = false;
        });

        await FirebaseAuth.instance.signOut();

        Navigator.of(context).pop();
      });
    } on FirebaseAuthException catch (erro) {
      setState(() {
        isLoading = false;
      });

      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: Text(
              erro.message!
                  .replaceAll(
                    'The password is invalid or the user does not have a password.',
                    'A senha é inválida',
                  )
                  .replaceAll('The email address is badly formatted.',
                      'O endereço de e-mail está formatado incorretamente.')
                  .replaceAll('Given String is empty or null',
                      'O campo de E-mail e Senha não pode estar vazio')
                  .replaceAll(
                      'There is no user record corresponding to this identifier. The user may have been deleted.',
                      'Não há registro de usuário correspondente a este identificador'),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Excluir Conta',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                Lottie.asset(
                  'assets/json/deleteaccount.json',
                  height: 250,
                ),
                const SizedBox(height: 15),
                Text(
                  'Tem Certeza ?',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ao excluir sua conta, você não poderá recuperá-la e perderá todos os dados cadastrados nela',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 50),
                TextFormField(
                  controller: passwordController,
                  onChanged: (value) {
                    setState(() {
                      passwordController;
                    });
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirme sua senha',
                    contentPadding: const EdgeInsets.all(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(800),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                isLoading == true
                    ? const CircularProgressIndicator.adaptive()
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: passwordController.text.isEmpty
                            ? null
                            : () {
                                deleteAccount();
                              },
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Excluir conta',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
