import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String selectedDate = DateTime.now().toIso8601String().split("T")[0]; // today

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance Records")),
      body: Column(
        children: [
          // Date Picker
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Text("Selected Date: $selectedDate"),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked.toIso8601String().split("T")[0];
                      });
                    }
                  },
                  child: Text("Pick Date"),
                ),
              ],
            ),
          ),

          // Attendance Table
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("attendance")
                  .where("date", isEqualTo: selectedDate)
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(child: Text("No attendance for this date"));
                }

                return ListView(
                  children: [
                    DataTable(
                      columns: const [
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Phone")),
                        DataColumn(label: Text("Bus")),
                        DataColumn(label: Text("Stop")),
                        DataColumn(label: Text("Time")),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(Text(data["name"] ?? "")),
                          DataCell(Text(data["phone"] ?? "")),
                          DataCell(Text(data["bus"] ?? "")),
                          DataCell(Text(data["stop"] ?? "")),
                          DataCell(Text(data["time"] ?? "")),
                        ]);
                      }).toList(),
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
