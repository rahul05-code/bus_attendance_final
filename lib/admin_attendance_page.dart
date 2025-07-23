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
        // Reset user selection when date changes
        selectedUser = null;
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      selectedDate = formatter.format(DateTime.now());
      selectedBus = null;
      selectedUser = null;
    });
  }

  bool get hasActiveFilters {
    final today = formatter.format(DateTime.now());
    return selectedDate != today || selectedBus != null || selectedUser != null;
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
          if (hasActiveFilters)
            IconButton(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear_all),
              tooltip: "Clear All Filters",
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Filters:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Date: $selectedDate',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (selectedBus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Bus: $selectedBus',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    if (selectedUser != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'User: $selectedUser',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    if (!hasActiveFilters)
                      const Text(
                        'No filters applied',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Date display
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Date: $selectedDate',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text("Change Date"),
                ),
              ],
            ),
          ),

          // Bus dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<String>(
                hint: const Text("Select Bus"),
                value: selectedBus,
                isExpanded: true,
                underline: const SizedBox(),
                onChanged: (value) {
                  setState(() {
                    selectedBus = value;
                    // Reset user selection when bus changes
                    selectedUser = null;
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
          ),

          // Attendance table
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
                          textAlign: TextAlign.center,
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
                        Icon(Icons.event_busy,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No attendance found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing the date or bus filter',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final allDocs = snapshot.data!.docs;

                // Get unique user names from filtered data
                final userNames = allDocs
                    .map((doc) =>
                        (doc.data() as Map<String, dynamic>)['name'] ?? '')
                    .where((name) => name.isNotEmpty)
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButton<String>(
                          hint: const Text("Select User"),
                          value: selectedUser,
                          isExpanded: true,
                          underline: const SizedBox(),
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
                    ),

                    // Records count
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${filteredDocs.length} of ${allDocs.length} records',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (filteredDocs.length != allDocs.length)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedUser = null;
                                });
                              },
                              child: const Text("Show All Users"),
                            ),
                        ],
                      ),
                    ),

                    // Data table
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(Colors.blue[50]),
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
                            rows: filteredDocs.asMap().entries.map((entry) {
                              final index = entry.key;
                              final doc = entry.value;
                              final data = doc.data() as Map;

                              return DataRow(
                                color: WidgetStateProperty.all(
                                  index % 2 == 0
                                      ? Colors.white
                                      : Colors.grey[50],
                                ),
                                cells: [
                                  DataCell(
                                    Text(
                                      data['name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(data['phone'] ?? '')),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        data['bus'] ?? '',
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(data['stop'] ?? '')),
                                  DataCell(
                                    Text(
                                      data['time'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(data['date'] ?? '')),
                                ],
                              );
                            }).toList(),
                          ),
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
