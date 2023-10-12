import 'package:brasil_fields/brasil_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nico/model/user_model.dart';
import 'package:nico/screens/auth_screens/login_screen.dart';
import 'package:nico/services/auth_service.dart';

class RegisterClient extends StatefulWidget {
  const RegisterClient({super.key});

  @override
  State<RegisterClient> createState() => _RegisterClientState();
}

class _RegisterClientState extends State<RegisterClient> {
  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final passowrdController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  submitForm() async {
    if (nameController.text.isEmpty) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Nome muito pequeno'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Voltar'),
              )
            ],
          );
        },
      );
    }

    if (cpfController.text.length < 14) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Cpf inválido'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Voltar'),
              )
            ],
          );
        },
      );
    }

    if (emailController.text.isEmpty) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Email inválido'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Voltar'),
              )
            ],
          );
        },
      );
    }

    if (passowrdController.text.isEmpty) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Senha inválida'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Voltar'),
              )
            ],
          );
        },
      );
    }

    if (confirmPasswordController.text != passowrdController.text) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Senhas diferentes'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Voltar'),
              )
            ],
          );
        },
      );
    }

    if (numberController.text.length < 15) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Número inválido'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Voltar'),
              )
            ],
          );
        },
      );
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passowrdController.text,
      )
          .then((value) async {
        AuthService().registerUsers(
          null,
          UserModel(
            cpf: cpfController.text,
            email: emailController.text,
            name: nameController.text,
            number: numberController.text,
            banned: false,
            isClient: true,
            establishmentId: null,
          ),
          context,
          true,
        );
      });
    } on FirebaseAuthException catch (erro) {
      // ignore: use_build_context_synchronously

      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: Text(
              erro.message!
                  .replaceAll(
                    'The email address is already in use by another account.',
                    'O endereço de e-mail já está sendo usado por outra conta.',
                  )
                  .replaceAll(
                    'Password should be at least 6 characters',
                    'A senha deve ter pelo menos 6 caracteres',
                  )
                  .replaceAll('The email address is badly formatted.',
                      'O endereço de e-mail está formatado incorretamente.')
                  .replaceAll('Given String is empty or null',
                      'O campo de E-mail e Senha não pode estar vazio'),
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
      backgroundColor: color.primary,
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/barber.jpeg'),
            fit: BoxFit.cover,
            opacity: 0.25,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: AppBar().preferredSize.height),

              // Image.asset(
              //   'assets/images/nico-white.png',
              //   scale: 10,
              // ),

              // const SizedBox(height: 20),

              // Register
              Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  alignment: Alignment.center,
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Registre-se',
                          style: GoogleFonts.montserrat(
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            hintText: 'Nome',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(800),
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: CircleAvatar(
                                child: Icon(
                                  Icons.person,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: cpfController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CpfInputFormatter(),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            hintText: 'Cpf',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(800),
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: CircleAvatar(
                                child: Icon(
                                  Icons.email,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            hintText: 'E-mail',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(800),
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: CircleAvatar(
                                child: Icon(
                                  Icons.email,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: numberController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            hintText: 'Número',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(800),
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: CircleAvatar(
                                child: Icon(
                                  Icons.phone,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: passowrdController,
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            hintText: 'Senha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(800),
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: CircleAvatar(
                                child: Icon(
                                  Icons.security_rounded,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            hintText: 'Confirme a senha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(800),
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: CircleAvatar(
                                child: Icon(
                                  Icons.security_rounded,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        _isLoading == true
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () {
                                  submitForm();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: color.primary),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Registrar-se',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false);
                          },
                          child: Text(
                            'Fazer login',
                            style: GoogleFonts.montserrat(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
