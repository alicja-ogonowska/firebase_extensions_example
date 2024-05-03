import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fsf_example/add_content_page.dart';
import 'package:fsf_example/content.dart';
import 'package:fsf_example/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Home'),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    final auth = FirebaseAuth.instance;
                    if (auth.currentUser != null) {
                      await auth.signOut();
                    } else {
                      await auth.signInAnonymously();
                    }
                  },
                  child: Text(userSnapshot.data != null ? 'Log out' : 'Log in'),
                ),
              ],
            ),
            body: userSnapshot.data != null
                ? StreamBuilder<QuerySnapshot>(
                    stream: contentsQuery(userSnapshot.data!.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.size,
                        itemBuilder: (BuildContext context, int idx) {
                          final content = Content.fromFirestore(
                              snapshot.data!.docs[idx]
                                  as DocumentSnapshot<Map<String, dynamic>>);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(content.message),
                          );
                        },
                      );
                    },
                  )
                : const Center(child: Text('Authenticate first')),
            floatingActionButton: userSnapshot.data != null
                ? FloatingActionButton(
                    onPressed: () {
                      _openAddContentPage(userSnapshot.data?.uid);
                    },
                    tooltip: 'Add new content',
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        });
  }

  void _openAddContentPage(String? userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddContentPage(),
      ),
    );
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('contents')
        .add(
          Content(
            message: 'test',
          ).toFirestore(),
        );
  }
}
