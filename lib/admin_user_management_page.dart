import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final List<String> busList = [
    "Morbi(Big)",
    "Morbi(Small)",
    "Gondal(Big)",
    "Gondal(Small)",
    "Rajkot",
    "Jasdan",
    "Wankaner"
  ];

  String? selectedBus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
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
              items: busList.map((bus) {
                return DropdownMenuItem<String>(
                  value: bus,
                  child: Text(bus),
                );
              }).toList(),
            ),
          ),

          // Clear Filter button
          if (selectedBus != null)
            TextButton(
              onPressed: () {
                setState(() {
                  selectedBus = null;
                });
              },
              child: const Text("Clear Filter"),
            ),

          // User List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedBus == null
                  ? FirebaseFirestore.instance.collection('users').snapshots()
                  : FirebaseFirestore.instance
                      .collection('users')
                      .where('bus', isEqualTo: selectedBus)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading users'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final user = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;

                    return ListTile(
                      title: Text(user['name'] ?? 'No Name'),
                      subtitle: Text(
                          "${user['phone'] ?? 'No Phone'} | ${user['bus'] ?? ''}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              // TODO: Add update user logic
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(id)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Add User Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add New User"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                // TODO: Implement add user dialog/page
              },
            ),
          ),
        ],
      ),
    );
  }
}
