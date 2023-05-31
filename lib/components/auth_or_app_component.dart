import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nico/model/user_model.dart';

import 'package:nico/screens/auth_screens/login_screen.dart';

import 'package:nico/screens/home_screen.dart';
import 'package:nico/screens/loading_screen.dart';

class AuthOrAppComponent extends StatefulWidget {
  const AuthOrAppComponent({super.key});

  @override
  State<AuthOrAppComponent> createState() => _AuthOrAppComponentState();
}

class _AuthOrAppComponentState extends State<AuthOrAppComponent> {
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
                UserModel userModel =
                    UserModel.fromJson(snapshot.data!.data()!);

                return HomeScreens(
                  userModel: userModel,
                );
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
