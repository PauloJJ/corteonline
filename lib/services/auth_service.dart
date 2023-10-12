import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nico/components/auth_or_app_component.dart';
import 'package:nico/model/barber_model.dart';
import 'package:nico/model/user_model.dart';

class AuthService extends ChangeNotifier {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  registerUsers(BarberModel? barberModel, UserModel? userModel,
      BuildContext context, bool isClient) async {
    if (isClient == false) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': barberModel!.name,
        'cpf': barberModel.cpf,
        'email': barberModel.email,
        'imageProfile': barberModel.imageProfile,
        'number': barberModel.number,
        'banned': barberModel.banned,
        'isClient': barberModel.isClient
      }).then(
        (value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => AuthOrAppComponent(index: 0),
          ),
          (route) => false,
        ),
      );
    } else {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': userModel!.name,
        'cpf': userModel.cpf,
        'email': userModel.email,
        'number': userModel.number,
        'banned': userModel.banned,
        'isClient': userModel.isClient,
        'establishmentId': null,
      }).then(
        (value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => AuthOrAppComponent(index: 0),
          ),
          (route) => false,
        ),
      );
    }
  }
}
