// views/landing_page.dart
import 'package:flutter/material.dart';
import 'package:hidden_words_front/views/admin/add_article.dart';
import 'package:hidden_words_front/views/admin/list_articles.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
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
              'Partie Admin',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddArticle(),
                        ),
                      );
                    },
                    child: const Text('Ajouter des articles'),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListArticles(),
                        ),
                      );
                    },
                    child: const Text('Lister les articles'),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[400])),
                    onPressed: () {},
                    child: const Text('Je sais pas encore (à venir)'),
                  ),
                ),
              ],
            ),
          ])),
    );
  }
}
