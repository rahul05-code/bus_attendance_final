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
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          if (selectedBus != null)
            IconButton(
              onPressed: () {
                setState(() {
                  selectedBus = null;
                });
              },
              icon: const Icon(Icons.clear),
              tooltip: "Clear Filter",
            ),
        ],
      ),
      body: Column(
        children: [
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
                hint: const Text("Select Bus to Filter"),
                value: selectedBus,
                isExpanded: true,
                underline: const SizedBox(),
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
                    return DropdownMenuItem<String>(
                      value: bus,
                      child: Text(bus),
                    );
                  }).toList(),
                ],
              ),
            ),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Error loading users'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedBus = null;
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          selectedBus == null
                              ? 'No users found.'
                              : 'No users found for $selectedBus',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        if (selectedBus != null) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedBus = null;
                              });
                            },
                            child: const Text("Show All Users"),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final user = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: Text(
                            (user['name'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user['name'] ?? 'No Name',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📞 ${user['phone'] ?? 'No Phone'}"),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user['bus'] ?? '',
                                    style: TextStyle(
                                      color: Colors.red[800],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  flex: 3,
                                  child: Text(
                                    "🚏 ${user['stop'] ?? 'No Stop'}",
                                    style: TextStyle(color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showEditUserDialog(id, user),
                              tooltip: "Edit User",
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteUser(
                                id,
                                user['name'] ?? 'Unknown User',
                              ),
                              tooltip: "Delete User",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add User"),
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final stopController = TextEditingController();
    String? userBus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add New User"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: userBus,
                  decoration: const InputDecoration(
                    labelText: "Bus",
                    border: OutlineInputBorder(),
                  ),
                  items: busList.map((bus) {
                    return DropdownMenuItem(
                      value: bus,
                      child: Text(bus),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      userBus = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stopController,
                  decoration: const InputDecoration(
                    labelText: "Stop",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    userBus != null &&
                    stopController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection('users').add({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'bus': userBus,
                      'stop': stopController.text.trim(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text("Add User"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(String docId, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['name'] ?? '');
    final phoneController =
        TextEditingController(text: userData['phone'] ?? '');
    final stopController = TextEditingController(text: userData['stop'] ?? '');
    String? userBus = userData['bus'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit User"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: userBus,
                  decoration: const InputDecoration(
                    labelText: "Bus",
                    border: OutlineInputBorder(),
                  ),
                  items: busList.map((bus) {
                    return DropdownMenuItem(
                      value: bus,
                      child: Text(bus),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      userBus = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stopController,
                  decoration: const InputDecoration(
                    labelText: "Stop",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    userBus != null &&
                    stopController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(docId)
                        .update({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'bus': userBus,
                      'stop': stopController.text.trim(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(String docId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete '$userName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(docId)
                    .delete();

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
