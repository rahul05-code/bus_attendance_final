import 'package:flutter/material.dart';
import 'api_service.dart'; // Assuming this import is correct for your API calls

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final stopCtrl = TextEditingController();
  final fieldCtrl = TextEditingController();
  final semCtrl = TextEditingController();

  String? city, bus;
  bool isLoading = false;

  final cities = ["Morbi", "Rajkot", "Gondal", "Tankara", "Jasdan", "Wankaner"];
  final buses = [
    "Morbi(Big)",
    "Morbi(Small)",
    "Gondal(Big)",
    "Gondal(Small)",
    "Rajkot",
    "Jasdan",
    "Wankaner"
  ];

  void register(BuildContext context) async {
    if (city == null || bus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select city and bus")), // Added const
      );
      return;
    }

    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        fieldCtrl.text.isEmpty ||
        semCtrl.text.isEmpty ||
        stopCtrl.text.isEmpty ||
        passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")), // Added const
      );
      return;
    }

    if (passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")), // Added const
      );
      return;
    }

    setState(() => isLoading = true);

    final res = await ApiService.registerUser(
      nameCtrl.text.trim(),
      emailCtrl.text.trim(),
      phoneCtrl.text.trim(),
      fieldCtrl.text.trim(),
      semCtrl.text.trim(),
      city!,
      bus!,
      stopCtrl.text.trim(),
      passCtrl.text.trim(),
    );

    setState(() => isLoading = false);

    final message =
        res["status"] == "success" ? "Registered successfully" : res["message"];

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (res["status"] == "success") {
      Navigator.pop(context); // Return to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Consistent white background
      appBar: AppBar(
        title: const Text(
          "Register Account", // More descriptive title
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red[700], // Match primary color
        elevation: 0, // No shadow for a flat, modern look
        iconTheme: const IconThemeData(color: Colors.white), // White back icon
      ),
      body: SafeArea( // Use SafeArea to avoid notch/status bar overlap
        child: SingleChildScrollView( // Changed to SingleChildScrollView for more robust scrolling
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // Increased padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch elements across width
            children: [
              const Text(
                "Create your student account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 30, 30, 30), // Darker text for heading
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Fill in the details below to get started.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Input Fields
              _buildInputField(
                  controller: nameCtrl,
                  labelText: "Full Name",
                  icon: Icons.person_outline),
              const SizedBox(height: 15),
              _buildInputField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  labelText: "Email Address",
                  icon: Icons.email_outlined),
              const SizedBox(height: 15),
              _buildInputField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  labelText: "Phone Number",
                  icon: Icons.phone_outlined),
              const SizedBox(height: 15),
              _buildInputField(
                  controller: fieldCtrl,
                  labelText: "Field (e.g., B.Tech, Diploma)",
                  icon: Icons.school_outlined), // More specific icon
              const SizedBox(height: 15),
              _buildInputField(
                  controller: semCtrl,
                  keyboardType: TextInputType.number,
                  labelText: "Semester (e.g., 1, 5)",
                  icon: Icons.format_list_numbered), // Number icon
              const SizedBox(height: 15),

              // Dropdowns
              _buildDropdownField(
                value: city,
                hintText: "Select City",
                items: cities,
                onChanged: (v) => setState(() => city = v),
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 15),
              _buildDropdownField(
                value: bus,
                hintText: "Select Bus Route", // More descriptive hint
                items: buses,
                onChanged: (v) => setState(() => bus = v),
                icon: Icons.directions_bus_outlined,
              ),
              const SizedBox(height: 15),

              _buildInputField(
                  controller: stopCtrl,
                  labelText: "Bus Stop Name",
                  icon: Icons.bus_alert_outlined), // Bus stop icon
              const SizedBox(height: 15),
              _buildInputField(
                  controller: passCtrl,
                  obscureText: true,
                  labelText: "Password",
                  icon: Icons.lock_outline),
              const SizedBox(height: 30),

              // Register Button
              ElevatedButton(
                onPressed: isLoading ? null : () => register(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700], // Deep red
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 5,
                  shadowColor: Colors.red.withOpacity(0.3),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white, // White spinner for visibility
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets for Professional UI ---

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red[700]!, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.transparent, width: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hintText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding for the dropdown content
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: InputBorder.none, // Remove default border
            prefixIcon: Icon(icon, color: Colors.grey[500]),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40), // Adjust icon spacing
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0), // Adjust padding for label/hint
          ),
          hint: Text(
            hintText,
            style: TextStyle(color: Colors.grey[600]),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white, // Background of the dropdown list
        ),
      ),
    );
  }
}