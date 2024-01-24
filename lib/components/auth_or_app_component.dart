import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nico/model/barber_model.dart';
import 'package:nico/model/user_model.dart';
import 'package:nico/screens/auth_screens/login_screen.dart';
import 'package:nico/screens/bottom_navigator.dart';
import 'package:nico/screens/loading_screen.dart';
import 'package:nico/screens/tutorial_screen.dart';

class AuthOrAppComponent extends StatefulWidget {
  final int index;

  AuthOrAppComponent({super.key, required this.index});

  @override
  State<AuthOrAppComponent> createState() => _AuthOrAppComponentState();
}

class _AuthOrAppComponentState extends State<AuthOrAppComponent> {
  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.logEvent(
      name: 'init_app',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userId = FirebaseAuth.instance.currentUser!.uid;

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (!snapshot.data!.exists) {
                  return const LoginScreen();
                } else {
                  if (snapshot.data!['isClient'] == false) {
                    BarberModel barberModel =
                        BarberModel.fromJson(snapshot.data!.data()!);

                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('daysAndHours')
                          .where('idEstablishment', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.isEmpty) {
                            return const TutorialScreen(isClient: false);
                          } else {
                            return BottomNavigator(
                              isClient: false,
                              index: widget.index,
                              barberModel: barberModel,
                            );
                          }
                        } else {
                          return const LoadingScreen();
                        }
                      },
                    );
                  } else {
                    UserModel userModel =
                        UserModel.fromJson(snapshot.data!.data()!);

                    if (userModel.establishmentId == null) {
                      return TutorialScreen(isClient: userModel.isClient);
                    } else {
                      return BottomNavigator(
                        index: widget.index,
                        isClient: true,
                        barberModel: null,
                      );
                    }
                  }
                }
              } else {
                return const LoadingScreen();
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
