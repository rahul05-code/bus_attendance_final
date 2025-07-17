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
  String? selectedBus;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  List<String> busList = [
    "Morbi(Big)",
    "Morbi(Small)",
    "Gondal(Big)",
    "Gondal(Small)",
    "Rajkot",
    "Jasdal",
    "Wankaner"
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = formatter.format(DateTime.now());
  }

  Stream<QuerySnapshot> getAttendanceStream(String date, String? bus) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('attendance')
        .where('date', isEqualTo: date);

    if (bus != null && bus.isNotEmpty) {
      query = query.where('bus', isEqualTo: bus);
    }

    // Safe ordering: only use fields you are sure always exist
    try {
      query = query.orderBy('time'); // Make sure ALL docs have 'time' field
    } catch (e) {
      debugPrint("OrderBy error: $e");
      // Skip ordering if error occurs
    }

    return query.snapshots();
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
      body: Column(
        children: [
          // Bus dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: const Text("Select Bus"),
              value: selectedBus,
              isExpanded: true,
              onChanged: (String? value) {
                setState(() {
                  selectedBus = value;
                });
              },
              items: busList.map((String bus) {
                return DropdownMenuItem<String>(
                  value: bus,
                  child: Text(bus),
                );
              }).toList()
                ..insert(
                    0,
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("All Buses"),
                    )),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAttendanceStream(selectedDate, selectedBus),
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
                        DataCell(Text(record['name']?.toString() ?? '')),
                        DataCell(Text(record['phone']?.toString() ?? '')),
                        DataCell(Text(record['bus']?.toString() ?? '')),
                        DataCell(Text(record['stop']?.toString() ?? '')),
                        DataCell(Text(record['time']?.toString() ?? '')),
                        DataCell(Text(record['date']?.toString() ?? '')),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
