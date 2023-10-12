import 'package:flutter/material.dart';
import 'package:nico/model/barber_model.dart';
import 'package:nico/screens/home_screen.dart';
import 'package:nico/screens/schedule_screen.dart';
import 'package:nico/screens/settings_screen.dart';

class BottomNavigator extends StatefulWidget {
  final int index;
  final bool isClient;
  final BarberModel? barberModel;

  const BottomNavigator({
    super.key,
    required this.index,
    required this.isClient,
    required this.barberModel,
  });

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    _indice = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      HomeScreens(barberModel: widget.barberModel),
      widget.isClient == true
          ? const ScheduleScreen()
          : const SettingsScreen(userModel: null, isClient: false),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _indice,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.cut_sharp),
            label: 'Agendar Corte',
          ),
          BottomNavigationBarItem(
            icon: widget.isClient == true
                ? Icon(Icons.schedule)
                : Icon(Icons.settings),
            label: widget.isClient == true
                ? 'Agendamentos'
                : 'Configurações de Perfil',
          ),
        ],
        onTap: (value) {
          setState(() {
            _indice = value;
          });
        },
      ),
      body: screens[_indice],
    );
  }
}
