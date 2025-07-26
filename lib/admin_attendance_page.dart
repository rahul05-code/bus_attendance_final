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
  final DateFormat displayFormatter = DateFormat('EEE, MMM d, yyyy');

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

      if (bus != null && bus.isNotEmpty && bus != 'All Buses') {
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[700],
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked.toIso8601String().substring(0, 10) != selectedDate) {
      setState(() {
        selectedDate = formatter.format(picked);
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
        title: const Text(
          "Attendance Dashboard", // Changed title
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.red[800],
        elevation: 0,
        centerTitle: true,
        actions: [
          if (hasActiveFilters)
            IconButton(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.filter_alt_off_outlined, color: Colors.white),
              tooltip: "Clear All Filters",
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Dashboard Overview & Filters Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red[800], // Red background matching app bar
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Attendance",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayFormatter.format(formatter.parse(selectedDate)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_outlined, color: Colors.red),
                      label: const Text(
                        "Change Date",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        hint: "All Buses",
                        value: selectedBus,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text("All Buses"),
                          ),
                          ...busList.map((bus) => DropdownMenuItem(value: bus, child: Text(bus))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedBus = value;
                            selectedUser = null;
                          });
                        },
                        dropdownColor: Colors.red[700], // Red dropdown background
                        textColor: Colors.white, // White text in dropdown
                        iconColor: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: getAttendanceStream(selectedDate, selectedBus),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildFilterDropdown(
                              hint: "Loading Users...",
                              value: null,
                              items: const [],
                              onChanged: (value) {},
                              dropdownColor: Colors.red[700],
                              textColor: Colors.white,
                              iconColor: Colors.white70,
                            );
                          }
                          final allDocs = snapshot.data?.docs ?? [];
                          final userNames = allDocs
                              .map((doc) => (doc.data() as Map<String, dynamic>)['name']?.toString() ?? '')
                              .where((name) => name.isNotEmpty)
                              .toSet()
                              .toList()
                            ..sort();

                          return _buildFilterDropdown(
                            hint: "All Users",
                            value: selectedUser,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text("All Users"),
                              ),
                              ...userNames.map((name) => DropdownMenuItem<String>(value: name, child: Text(name))),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedUser = value;
                              });
                            },
                            dropdownColor: Colors.red[700],
                            textColor: Colors.white,
                            iconColor: Colors.white70,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (hasActiveFilters)
                  Center(
                    child: TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: Icon(Icons.refresh_outlined, size: 18, color: Colors.white70),
                      label: Text(
                        "Reset Filters",
                        style: TextStyle(color: Colors.white70),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Attendance Records List/Table
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAttendanceStream(selectedDate, selectedBus),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildEmptyOrErrorState(
                    icon: Icons.error_outline,
                    message: 'Error loading data: ${snapshot.error}',
                    subMessage: 'Please try again or contact support.',
                    iconColor: Colors.redAccent,
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.red),
                        SizedBox(height: 20),
                        Text(
                          'Fetching attendance records...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final allDocs = snapshot.data!.docs;
                final filteredDocs = selectedUser == null || selectedUser == 'All Users'
                    ? allDocs
                    : allDocs.where((doc) {
                        final name = (doc.data() as Map)['name']?.toString() ?? '';
                        return name == selectedUser;
                      }).toList();

                filteredDocs.sort((a, b) {
                  final aTime = (a.data() as Map)['time']?.toString() ?? '';
                  final bTime = (b.data() as Map)['time']?.toString() ?? '';
                  return aTime.compareTo(bTime);
                });

                if (filteredDocs.isEmpty) {
                  return _buildEmptyOrErrorState(
                    icon: Icons.receipt_long_outlined,
                    message: 'No records match your filters.',
                    subMessage: 'Try adjusting the date, bus, or user selections.',
                    iconColor: Colors.grey[300]!,
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total entries: ${filteredDocs.length}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (selectedUser != null && selectedUser != 'All Users')
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  selectedUser = null;
                                });
                              },
                              icon: Icon(Icons.person_remove_outlined, size: 16, color: Colors.grey[500]),
                              label: Text(
                                "Clear User Filter",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Scrollbar( // Added scrollbar
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          scrollDirection: Axis.horizontal,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.grey[100]), // Lighter header for table
                              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.red.withOpacity(0.1);
                                  }
                                  return null;
                                },
                              ),
                              border: TableBorder.all(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              columnSpacing: 40, // More spacing
                              dataRowHeight: 55, // Taller rows
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    "Name",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Phone",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Field",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Semester",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Bus",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Stop",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Time",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Date",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                              ],
                              rows: filteredDocs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final doc = entry.value;
                                final data = doc.data() as Map<String, dynamic>;

                                return DataRow(
                                  color: WidgetStateProperty.all(
                                    index % 2 == 0 ? Colors.white : Colors.grey[50],
                                  ),
                                  cells: [
                                    DataCell(
                                      Text(
                                        data['name']?.toString() ?? 'N/A',
                                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                                      ),
                                    ),
                                    DataCell(Text(data['phone']?.toString() ?? 'N/A')),
                                    DataCell(Text(data['field']?.toString() ?? 'N/A')),
                                    DataCell(Text(data['sem']?.toString() ?? 'N/A')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          data['bus']?.toString() ?? 'N/A',
                                          style: TextStyle(
                                            color: Colors.red[800],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(data['stop']?.toString() ?? 'N/A')),
                                    DataCell(
                                      Text(
                                        data['time']?.toString() ?? 'N/A',
                                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey),
                                      ),
                                    ),
                                    DataCell(Text(data['date']?.toString() ?? 'N/A')),
                                  ],
                                );
                              }).toList(),
                            ),
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

  // --- Helper Widgets for Cleaner Code ---

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    Color? dropdownColor,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // Translucent white for filters
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5), // Subtle white border
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: TextStyle(color: textColor?.withOpacity(0.8) ?? Colors.white70)),
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: iconColor ?? Colors.white70),
          onChanged: onChanged,
          items: items,
          style: TextStyle(color: textColor ?? Colors.white, fontSize: 15),
          dropdownColor: dropdownColor ?? Colors.red[700], // Background of the dropdown menu
        ),
      ),
    );
  }

  Widget _buildEmptyOrErrorState({
    required IconData icon,
    required String message,
    required String subMessage,
    required Color iconColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: iconColor),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}