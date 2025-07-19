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

      // Remove orderBy to avoid index issues and potential crashes
      // We'll sort the data in the UI instead
      return query.snapshots();
    } catch (e) {
      debugPrint("Query error: $e");
      // Return empty stream in case of error
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
        title: const Text("Admin Attendance Panel"),
        backgroundColor: Colors.blue,
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<String>(
                hint: const Text("Select Bus (All Buses)"),
                value: selectedBus,
                isExpanded: true,
                underline: const SizedBox(),
                onChanged: (String? value) {
                  setState(() {
                    selectedBus = value;
                  });
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text("All Buses"),
                  ),
                  ...busList.map((String bus) {
                    return DropdownMenuItem<String>(
                      value: bus,
                      child: Text(bus),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Attendance list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAttendanceStream(selectedDate, selectedBus),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Refresh the page
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading attendance records...'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No attendance records found for $selectedDate',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (selectedBus != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Bus: $selectedBus',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final data = snapshot.data!.docs;

                // Sort data by time in the UI to avoid Firestore index issues
                data.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['time']?.toString() ?? '';
                  final bTime = bData['time']?.toString() ?? '';
                  return aTime.compareTo(bTime);
                });

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Records: ${data.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                              MaterialStateProperty.all(Colors.blue[50]),
                          border: TableBorder.all(color: Colors.grey[300]!),
                          columns: const [
                            DataColumn(
                              label: Text(
                                "Name",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Phone",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Bus",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Stop",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Time",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Date",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: data.map((doc) {
                            final record = doc.data() as Map<String, dynamic>;

                            return DataRow(
                              cells: [
                                DataCell(
                                    Text(record['name']?.toString() ?? 'N/A')),
                                DataCell(
                                    Text(record['phone']?.toString() ?? 'N/A')),
                                DataCell(
                                    Text(record['bus']?.toString() ?? 'N/A')),
                                DataCell(
                                    Text(record['stop']?.toString() ?? 'N/A')),
                                DataCell(
                                    Text(record['time']?.toString() ?? 'N/A')),
                                DataCell(
                                    Text(record['date']?.toString() ?? 'N/A')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
