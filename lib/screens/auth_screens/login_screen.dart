import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:nico/components/auth_or_app_component.dart';
import 'package:nico/components/register_cliente_or_barber_component.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passowrdController = TextEditingController();

  bool _isLoading = false;

  submitForm() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passowrdController.text)
          .then((value) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => AuthOrAppComponent(index: 0),
              ),
              (route) => false));
    } on FirebaseAuthException catch (erro) {
      print(erro);
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
                      'Não há registro de usuário correspondente a este identificador.'),
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

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppBar().preferredSize.height * 2),

                Image.asset(
                  'assets/images/branco.png',
                  scale: 2.70,
                ),

                const SizedBox(height: 50),

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
                            'Login',
                            style: GoogleFonts.montserrat(
                              fontSize: 30,
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
                                      'Login',
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterClientOrBarberComponent(),
                                ),
                              );
                            },
                            child: Text(
                              'Registrar-se',
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
      ),
    );
  }
}
