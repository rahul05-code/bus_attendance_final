import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminAttendancePage extends StatefulWidget {
  const AdminAttendancePage({super.key});

  @override
  State<AdminAttendancePage> createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends State<AdminAttendancePage> {
  late String selectedDate;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    selectedDate = formatter.format(DateTime.now());
  }

  Stream<QuerySnapshot> getAttendanceStream(String date) {
    return FirebaseFirestore.instance
        .collection('attendance')
        .where('date', isEqualTo: date)
        .orderBy('time')
        .snapshots();
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: formatter.parse(selectedDate),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = formatter.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Attendance Panel"),
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAttendanceStream(selectedDate),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) {
            return const Center(child: Text('No attendance records.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Phone")),
                DataColumn(label: Text("Bus")),
                DataColumn(label: Text("Stop")),
                DataColumn(label: Text("Time")),
                DataColumn(label: Text("Date")),
              ],
              rows: data.map((doc) {
                final record = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(record['name'] ?? '')),
                  DataCell(Text(record['phone'] ?? '')),
                  DataCell(Text(record['bus'] ?? '')),
                  DataCell(Text(record['stop'] ?? '')),
                  DataCell(Text(record['time'] ?? '')),
                  DataCell(Text(record['date'] ?? '')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
