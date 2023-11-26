// views/landing_page.dart
import 'package:flutter/material.dart';
import 'package:hidden_words_front/views/admin/admin.dart';
import 'package:hidden_words_front/views/gamemodes/infernal_mode.dart';
import 'package:hidden_words_front/views/gamemodes/normal_mode.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidden Words'),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            const Text(
              'Bienvenue sur Hidden Words !',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Modes de jeu',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InfernalMode(),
                            ),
                          );
                        },
                        child: const Text('Mode infernal'),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NormalMode(),
                            ),
                          );
                        },
                        child: const Text('Mode normal'),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.grey[400])),
                        onPressed: () {},
                        child: const Text('Mode par difficulté (à venir)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Admin(),
            ),
          );
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.admin_panel_settings_sharp), Text("Admin")],
        ),
      ),
    );
  }
}
