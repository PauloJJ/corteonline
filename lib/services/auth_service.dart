import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nico/components/auth_or_app_component.dart';
import 'package:nico/model/user_model.dart';

class AuthService extends ChangeNotifier {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  registerUser(UserModel userModel, BuildContext context) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': userModel.name,
      'email': userModel.email,
      'imageProfile': userModel.imageProfile,
      'number': userModel.number,
      'banned': userModel.banned,
    }).then(
      (value) => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const AuthOrAppComponent(),
        ),
        (route) => false,
      ),
    );
  }
}
