import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
// 1. Initialize Flutter and Firebase
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

// 2. Function to Send a New Poll to Firebase
void _addNewPoll() {
if (_pollController.text.isNotEmpty) {
FirebaseFirestore.instance.collection('polls').add({
'question': _pollController.text,
'votes': 0,
'createdAt': Timestamp.now(),
});
_pollController.clear(); // Clears the input box after sending
}
}

// 3. Function to Update the Vote Count in Firebase
void _submitVote(String documentId, int currentVotes) {
FirebaseFirestore.instance.collection('polls').doc(documentId).update({
'votes': currentVotes + 1,
});
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
// Input Area at the top
Padding(
padding: const EdgeInsets.all(15.0),
child: Row(
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
),

],
),
);
}


}



















