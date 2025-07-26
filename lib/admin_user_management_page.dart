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
      backgroundColor: Colors.white, // Pure white background for a clean look
      appBar: AppBar(
        title: const Text(
          "Manage Student Accounts", // More formal and descriptive title
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700, // Slightly bolder title
            letterSpacing: 0.5, // A little letter spacing
          ),
        ),
        backgroundColor: const Color(0xFFC62828), // Deeper, specific red (Red 800)
        elevation: 4, // A subtle shadow for depth
        foregroundColor: Colors.white,
        actions: [
          if (selectedBus != null)
            IconButton(
              onPressed: () {
                setState(() {
                  selectedBus = null;
                });
              },
              icon: const Icon(Icons.filter_alt_off_outlined), // More direct "filter off" icon
              tooltip: "Clear Filter",
            ),
          const SizedBox(width: 8), // Add some spacing to the right
        ],
      ),
      body: Column(
        children: [
          // Bus dropdown filter section
          Padding(
            padding: const EdgeInsets.all(16.0), // Uniform padding
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade300), // Light border
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08), // Softer shadow
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // More pronounced shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text(
                    "Filter by Bus Route",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  value: selectedBus,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700), // Darker arrow
                  onChanged: (value) {
                    setState(() {
                      selectedBus = value;
                    });
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        "All Students", // More appropriate text
                        style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ...busList.map((bus) {
                      return DropdownMenuItem<String>(
                        value: bus,
                        child: Text(
                          bus,
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      );
                    }).toList(),
                  ],
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade900),
                  dropdownColor: Colors.white,
                ),
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
                        Icon(Icons.cloud_off_outlined, size: 72, color: Colors.grey.shade400),
                        const SizedBox(height: 24),
                        const Text(
                          'Failed to load user data.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedBus = null;
                            });
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Try Again', style: TextStyle(color: Colors.white, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC62828)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search,
                            size: 72, color: Colors.grey.shade300),
                        const SizedBox(height: 24),
                        Text(
                          selectedBus == null
                              ? 'No student accounts found.'
                              : 'No students found for "${selectedBus!}" bus route.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        if (selectedBus != null) ...[
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedBus = null;
                              });
                            },
                            icon: const Icon(Icons.group_outlined, color: Color(0xFFC62828)),
                            label: const Text(
                              "View All Students",
                              style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final user = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.white,
                      child: Padding( // <--- Reverted to using Padding directly, simplified structure
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Consistent padding
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in the center
                          children: [
                            // Leading Avatar
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFFEF9A9A),
                              child: Text(
                                (user['name'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFB71C1C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16), // Space between avatar and content

                            // Main content (Title and Subtitle)
                            Expanded( // Allows this column to take available space
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min, // Allow column to shrink wrap
                                children: [
                                  Text(
                                    user['name'] ?? 'No Name',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "📞 ${user['phone'] ?? 'No Phone'}",
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                                  ),
                                  const SizedBox(height: 10),

                                  // Bus shown as a stylish chip
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Chip(
                                      label: Text(
                                        user['bus'] ?? 'N/A',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFFC62828),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Flexible for long text
                                  Text( // Changed Flexible to just Text, as Expanded handles horizontal constraints
                                    "📍 Stop: ${user['stop'] ?? 'No Stop'}",
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    "📚 Field: ${user['field'] ?? 'N/A'}",
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "🗓️ Semester: ${user['sem'] ?? 'N/A'}",
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),

                            // Trailing Icons
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min, // Important for wrapping content
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_note_outlined, color: Colors.blueAccent, size: 28),
                                  onPressed: () => _showEditUserDialog(id, user),
                                  tooltip: "Edit User",
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(height: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_forever_outlined, color: Color(0xFFD32F2F), size: 28),
                                  onPressed: () => _confirmDeleteUser(
                                    id,
                                    user['name'] ?? 'Unknown User',
                                  ),
                                  tooltip: "Delete User",
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
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
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1, size: 28),
        label: const Text(
          "Add New Student",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
      ),
    );
  }

  // Helper Dialogs and Widgets (remain unchanged)

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final stopController = TextEditingController();
    final fieldController = TextEditingController();
    final semController = TextEditingController();
    String? userBus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add New Student",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                    controller: nameController,
                    labelText: "Full Name",
                    icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    controller: phoneController,
                    labelText: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    controller: fieldController,
                    labelText: "Field (e.g., B.Tech, Diploma)",
                    icon: Icons.school_outlined),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    controller: semController,
                    labelText: "Semester (e.g., 1, 5)",
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildDialogDropdownField(
                  value: userBus,
                  hintText: "Select Bus Route",
                  items: busList,
                  onChanged: (value) => setDialogState(() => userBus = value),
                  icon: Icons.directions_bus_outlined,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    controller: stopController,
                    labelText: "Bus Stop Name",
                    icon: Icons.location_on_outlined),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  textStyle: const TextStyle(fontSize: 16)),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    fieldController.text.isNotEmpty &&
                    semController.text.isNotEmpty &&
                    userBus != null &&
                    stopController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection('users').add({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'field': fieldController.text.trim(),
                      'sem': semController.text.trim(),
                      'bus': userBus,
                      'stop': stopController.text.trim(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Student added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding student: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: const Text("Add Student"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(String docId, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['name'] ?? '');
    final phoneController = TextEditingController(text: userData['phone'] ?? '');
    final stopController = TextEditingController(text: userData['stop'] ?? '');
    final fieldController = TextEditingController(text: userData['field'] ?? '');
    final semController = TextEditingController(text: userData['sem'] ?? '');
    String? userBus = userData['bus'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Student Details",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                    controller: nameController,
                    labelText: "Full Name",
                    icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    controller: phoneController,
                    labelText: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    controller: fieldController,
                    labelText: "Field (e.g., B.Tech, Diploma)",
                    icon: Icons.school_outlined),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    controller: semController,
                    labelText: "Semester (e.g., 1, 5)",
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildDialogDropdownField(
                  value: userBus,
                  hintText: "Select Bus Route",
                  items: busList,
                  onChanged: (value) => setDialogState(() => userBus = value),
                  icon: Icons.directions_bus_outlined,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    controller: stopController,
                    labelText: "Bus Stop Name",
                    icon: Icons.location_on_outlined),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  textStyle: const TextStyle(fontSize: 16)),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    fieldController.text.isNotEmpty &&
                    semController.text.isNotEmpty &&
                    userBus != null &&
                    stopController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(docId)
                        .update({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'field': fieldController.text.trim(),
                      'sem': semController.text.trim(),
                      'bus': userBus,
                      'stop': stopController.text.trim(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Student updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating student: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: const Text("Update Student"),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Deletion",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
        content: Text(
          "Are you sure you want to permanently delete the student account for '$userName'? This action cannot be undone.",
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                textStyle: const TextStyle(fontSize: 16)),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      content: Text('Student deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting student: $e'),
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

  // Helper widget for consistent TextField styling in dialogs
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Color(0xFFC62828), width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
      ),
    );
  }

  // Helper widget for consistent DropdownButtonFormField styling in dialogs
  Widget _buildDialogDropdownField({
    required String? value,
    required String hintText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Color(0xFFC62828), width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
      style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
      dropdownColor: Colors.white,
      isExpanded: true,
    );
  }
}