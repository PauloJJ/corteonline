import 'package:flutter/material.dart';
import 'package:nico/components/tutorial_barber_component.dart';
import 'package:nico/components/tutorial_client_component.dart';

class TutorialScreen extends StatefulWidget {
  final bool isClient;
  const TutorialScreen({super.key, required this.isClient});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.isClient == true) {
      return const TutorialClientComponent();
    } else {
      return const TutorialBarberComponent();
    }
  }
}
