import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

  // Category variables
  final List<String> _categories = ['Education', 'Sports', 'Tech'];
  String _selectedCategory = 'Education';

  void _addNewPoll() {
    if (_pollController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('polls').add({
        'question': _pollController.text,
        'votes': 0,
        'category': _selectedCategory, //
        'createdAt': Timestamp.now(),
      });
      _pollController.clear();
    }
  }

  void _submitVote(String documentId, int currentVotes) {
    FirebaseFirestore.instance.collection('polls').doc(documentId).update({
      'votes': currentVotes + 1,
    });
  }

  // Logic to sum all votes from all polls
  int _calculateTotalVotes(List<QueryDocumentSnapshot> docs) {
    int total = 0;
    for (var doc in docs) {
      total += (doc['votes'] as int); //
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
          // Input Area with Category Dropdown
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pollController,
                        decoration: const InputDecoration(
                          hintText: 'Type a question here...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addNewPoll,
                      child: const Text('Post'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Dropdown for Category selection
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Select Category'),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),

          // Real-time List of Polls
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('polls').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                final totalVotes = _calculateTotalVotes(docs);

                return Column(
                  children: [
                    // Total Votes Summary Bar
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.blue.withOpacity(0.1),
                      width: double.infinity,
                      child: Text(
                        'Total Votes in System: $totalVotes',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
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
                              title: Text(data['question']),
                              subtitle: Text('Category: ${data['category'] ?? 'General'}'), //
                              trailing: ElevatedButton(
                                onPressed: () => _submitVote(docs[index].id, data['votes']),
                                child: Text('Vote: ${data['votes']}'),
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