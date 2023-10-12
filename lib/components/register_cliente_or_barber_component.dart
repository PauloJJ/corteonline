import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nico/screens/auth_screens/register_barber_screen.dart';
import 'package:nico/screens/auth_screens/register_client_screen.dart';

class RegisterClientOrBarberComponent extends StatefulWidget {
  const RegisterClientOrBarberComponent({super.key});

  @override
  State<RegisterClientOrBarberComponent> createState() =>
      _RegisterClientOrBarberComponentState();
}

class _RegisterClientOrBarberComponentState
    extends State<RegisterClientOrBarberComponent> {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: AppBar().preferredSize.height * 0.5),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Como gostaria de se registrar ?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterClient(),
                                ));
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 212, 228, 255),
                                radius: 180,
                                child: Lottie.asset(
                                    'assets/json/person_client.json'),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: size.width * 0.6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Sou um cliente',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                        Text(
                                          'Procurando meu Salão/Barberia',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterBarberScreen(),
                            ));
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 212, 228, 255),
                                radius: 180,
                                child: Container(
                                  height: size.height * 0.33,
                                  width: size.width,
                                  alignment: Alignment.topCenter,
                                  child: Lottie.asset(
                                    'assets/json/barber.json',
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: size.width * 0.6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Sou um estabelecimento',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                        Text(
                                          'E quero automatizar os meus agendamentos',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Voltar',
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
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
