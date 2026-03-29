import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Web requires manual configuration to avoid the white screen
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR-API-KEY",
        authDomain: "YOUR-PROJECT-ID.firebaseapp.com",
        projectId: "YOUR-PROJECT-ID",
        storageBucket: "YOUR-PROJECT-ID.appspot.com",
        messagingSenderId: "YOUR-SENDER-ID",
        appId: "YOUR-APP-ID",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(const PollApp());
}

class PollApp extends StatelessWidget {
  const PollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poll Voting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PollHomeScreen(),
    );
  }
}

class PollHomeScreen extends StatefulWidget {
  const PollHomeScreen({super.key});

  @override
  State<PollHomeScreen> createState() => _PollHomeScreenState();
}

class _PollHomeScreenState extends State<PollHomeScreen> {
  final TextEditingController _pollController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _categories = ['Education', 'Sports', 'Tech', 'General'];
  String _selectedCategory = 'Education';

  void _addNewPoll() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('polls').add({
        'question': _pollController.text.trim(),
        'votes': 0,
        'category': _selectedCategory,
        'createdAt': FieldValue.serverTimestamp(), // Best for cross-platform sync
      });
      _pollController.clear();
    }
  }

  void _submitVote(String documentId, int currentVotes) {
    FirebaseFirestore.instance.collection('polls').doc(documentId).update({
      'votes': currentVotes + 1,
    });
  }

  int _calculateTotalVotes(List<QueryDocumentSnapshot> docs) {
    int total = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['votes'] as int? ?? 0); // Null safety check
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Poll System'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pollController,
                          decoration: const InputDecoration(
                            hintText: 'Type a question here...',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? 'Enter a question' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addNewPoll, 
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
                        child: const Text('Post'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Select Category', border: OutlineInputBorder()),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('polls').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data!.docs;
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.blue.withOpacity(0.1), // Stable for Web
                      width: double.infinity,
                      child: Text(
                        'Total Votes in System: ${_calculateTotalVotes(docs)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: ListTile(
                              title: Text(data['question'] ?? ''),
                              subtitle: Text('Category: ${data['category'] ?? 'General'}', style: const TextStyle(fontStyle: FontStyle.italic)),
                              trailing: ElevatedButton(
                                onPressed: () => _submitVote(docs[index].id, data['votes'] ?? 0),
                                child: Text('Vote: ${data['votes'] ?? 0}'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}