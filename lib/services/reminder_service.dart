import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReminder(Map<String, dynamic> reminder) async {
    await _firestore.collection('reminders').add(reminder);
  }

  Future<void> updateReminder(String id, Map<String, dynamic> newData) async {
  await _firestore.collection('reminders').doc(id).update(newData);
}

Future<void> deleteReminder(String id) async {
  await _firestore.collection('reminders').doc(id).delete();
}

  Future<List<Map<String, dynamic>>> fetchReminders() async {
    final snapshot = await _firestore.collection('reminders').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}

