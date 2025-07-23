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
  String? selectedUser;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  List<String> busList = [
    "Morbi(Big)",
    "Morbi(Small)",
    "Gondal(Big)",
    "Gondal(Small)",
    "Rajkot",
    "Jasdan",
    "Wankaner"
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = formatter.format(DateTime.now());
  }

  Stream<QuerySnapshot> getAttendanceStream(String date, String? bus) {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('attendance')
          .where('date', isEqualTo: date);

      if (bus != null && bus.isNotEmpty) {
        query = query.where('bus', isEqualTo: bus);
      }

      return query.snapshots();
    } catch (e) {
      debugPrint("Query error: $e");
      return const Stream.empty();
    }
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
        title: const Text("Attendance Records"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Text(
              'Selected Date: $selectedDate',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Bus dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              hint: const Text("Select Bus"),
              value: selectedBus,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedBus = value;
                });
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text("All Buses"),
                ),
                ...busList.map((bus) {
                  return DropdownMenuItem(
                    value: bus,
                    child: Text(bus),
                  );
                }).toList(),
              ],
            ),
          ),

          // Attendance table
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAttendanceStream(selectedDate, selectedBus),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No attendance found'));
                }

                final allDocs = snapshot.data!.docs;

                // Get unique user names
                final userNames = allDocs
                    .map((doc) =>
                        (doc.data() as Map<String, dynamic>)['name'] ?? '')
                    .toSet()
                    .toList()
                  ..sort();

                // Filter by user name
                final filteredDocs = selectedUser == null
                    ? allDocs
                    : allDocs.where((doc) {
                        final name = (doc.data() as Map)['name'] ?? '';
                        return name == selectedUser;
                      }).toList();

                // Sort by time
                filteredDocs.sort((a, b) {
                  final aTime = (a.data() as Map)['time'] ?? '';
                  final bTime = (b.data() as Map)['time'] ?? '';
                  return aTime.compareTo(bTime);
                });

                return Column(
                  children: [
                    // User dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButton<String>(
                        hint: const Text("Select User"),
                        value: selectedUser,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            selectedUser = value;
                          });
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text("All Users"),
                          ),
                          ...userNames.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(Colors.blue[50]),
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columns: const [
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("Phone")),
                            DataColumn(label: Text("Bus")),
                            DataColumn(label: Text("Stop")),
                            DataColumn(label: Text("Time")),
                            DataColumn(label: Text("Date")),
                          ],
                          rows: filteredDocs.map((doc) {
                            final data = doc.data() as Map;
                            return DataRow(
                              cells: [
                                DataCell(Text(data['name'] ?? '')),
                                DataCell(Text(data['phone'] ?? '')),
                                DataCell(Text(data['bus'] ?? '')),
                                DataCell(Text(data['stop'] ?? '')),
                                DataCell(Text(data['time'] ?? '')),
                                DataCell(Text(data['date'] ?? '')),
                              ],
                            );
                          }).toList(),
                        ),
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

class string {}
