import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAttendancePage extends StatelessWidget {
  const AdminAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String today = DateTime.now().toIso8601String().split("T")[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Attendance Panel'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('date', isEqualTo: today)
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No attendance found for today."));
          }

          final docs = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Phone")),
                DataColumn(label: Text("Bus")),
                DataColumn(label: Text("Stop")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Time")),
              ],
              rows: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(data['name'] ?? '')),
                  DataCell(Text(data['phone'] ?? '')),
                  DataCell(Text(data['bus'] ?? '')),
                  DataCell(Text(data['stop'] ?? '')),
                  DataCell(Text(data['date'] ?? '')),
                  DataCell(Text(data['time'] ?? '')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
