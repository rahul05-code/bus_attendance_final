// lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scan_page.dart'; // Ensure this file exists and contains your ScanPage widget
import 'login_page.dart'; // Ensure this file exists and contains your LoginPage widget

class HomePage extends StatefulWidget {
  const HomePage({super.key}); // Best practice: add const constructor with super.key

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Use private variables with _ prefix for better encapsulation (Flutter convention)
  String _name = "Loading...";
  String _phone = "Loading...";
  String _field = "Loading...";
  String _sem = "Loading...";
  String _stop = "Loading...";
  String _city = "Loading...";
  String _bus = "Loading...";

  bool _isLoading = true; // State to show loading indicator
  bool _hasError = false; // State to show error message if data fetch fails

  @override
  void initState() {
    super.initState();
    _loadUser(); // Initiate loading user data when the widget is created
  }

  // Asynchronously loads user data from Firestore
  void _loadUser() async {
    setState(() {
      _isLoading = true; // Show loading indicator
      _hasError = false; // Clear any previous error
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If user is not logged in, navigate to the login page.
        // `mounted` check prevents errors if widget is disposed before async operation completes.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not logged in. Redirecting...")),
          );
          // pushReplacement removes the current route, so user can't go back to HomePage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        }
        return; // Exit function early
      }

      final uid = user.uid; // Get the unique ID of the current authenticated user
      // Fetch the user's document from the 'users' collection in Firestore
      final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (doc.exists) {
        // If the document exists, extract the data map
        final data = doc.data()!; // ! asserts that data is not null
        setState(() {
          // Update state variables with data from Firestore, providing "N/A" if field is null
          _name = data["name"] ?? "N/A";
          _phone = data["phone"] ?? "N/A";
          _field = data["field"] ?? "N/A";
          _sem = data["sem"] ?? "N/A";
          _stop = data["stop"] ?? "N/A";
          _city = data["city"] ?? "N/A";
          _bus = data["bus"] ?? "N/A";
          _isLoading = false; // Hide loading indicator
        });
      } else {
        // If no user document found for the UID
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found in Firestore.")),
          );
        }
        setState(() {
          _isLoading = false; // Hide loading indicator
          _hasError = true; // Set error state
        });
      }
    } catch (e) {
      // Catch any exceptions that occur during the data fetching process
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading user data: $e")), // Display the error
        );
      }
      setState(() {
        _isLoading = false; // Hide loading indicator
        _hasError = true; // Set error state
      });
    }
  }

  // Helper method to build a consistently styled row for displaying user details
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Vertical spacing for each row
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Vertically align icon and text
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24), // Icon with primary color
          const SizedBox(width: 15), // Spacing between icon and text
          Expanded( // Allows text to take remaining space, preventing overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
              children: [
                Text(
                  label, // Label for the data field (e.g., "Name")
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600], // Muted color for labels
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4), // Small spacing between label and value
                Text(
                  value.isNotEmpty ? value : "N/A", // Display value or "N/A" if empty
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold, // Bold for the value
                    color: Colors.black87, // Dark color for readability
                  ),
                  overflow: TextOverflow.ellipsis, // Truncate long text with ellipsis
                  maxLines: 1, // Limit value to a single line
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for contact information rows with overflow fix
  Widget _buildContactRow(String name, String role, String phone, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          // Phone row
          Row(
            children: [
              Icon(Icons.phone, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Flexible( // Allows phone number to wrap or ellipsis
                child: Text(
                  phone,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Space between phone and email rows
          // Email row
          Row(
            children: [
              Icon(Icons.email, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Flexible( // Allows email to wrap to multiple lines
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to show the contact details in a dialog
  void _showContactDialog(BuildContext context) {
    // You can also use Theme.of(context).primaryColor if your theme is set to red
    final Color primaryRed = Colors.red.shade700;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          titlePadding: const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 0),
          contentPadding: const EdgeInsets.all(25),
          actionsPadding: const EdgeInsets.only(right: 20, bottom: 15),
          title: Text(
            "Contact Details",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryRed,
            ),
          ),
          content: SingleChildScrollView( // Use SingleChildScrollView for dialog content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Make column only take up needed space
              children: [
                const Divider(height: 30, thickness: 1.5, color: Colors.grey),
                _buildContactRow(
                  "Aghera Bansi",
                  "App Devloper", // Placeholder role
                  "+91 93274 09568", // Placeholder phone
                  "agherabansi2@gmail.com", // Placeholder email
                ),
                const Divider(height: 20, thickness: 0.5, color: Colors.grey), // Subtle divider between contacts
                _buildContactRow(
                  "Kanzariya Rahu",
                  "App Devloper", // Placeholder role
                  "+91 97121 55571", // Placeholder phone
                  "kanzariyarahul31@gmail.com", // Placeholder email
                ),
                _buildContactRow(
                  "Vallabh Bhai",
                  "Bus Management", // Placeholder role
                  "+91 97128 61066", // Placeholder phone
                  "vallabhbhai@gmail.com", // Placeholder email
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Close",
                style: TextStyle(color: primaryRed, fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to handle user logout
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the current user
      if (mounted) {
        // Navigate to LoginPage and remove all previous routes from the stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
          (Route<dynamic> route) => false, // Remove all previous routes
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged out successfully!")), // Inform user
        );
      }
    } catch (e) {
      // Handle any errors during logout
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Defining a primary red color to be used consistently
    final Color primaryRed = Colors.red.shade700; // A darker, professional red
    final Color accentRed = Colors.red.shade400; // A slightly lighter red for accents

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed, // Appbar is now RED
        foregroundColor: Colors.white, // Text and icons on app bar are white
        // Dynamic title showing user's name if loaded, otherwise "Welcome!"
        title: Text(
          _name.isNotEmpty && _name != "Loading..." ? "Welcome, $_name!" : "Welcome!",
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: Colors.white) ??
                 const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Logout IconButton in the app bar (Contact Us button moved to body)
          IconButton(
            icon: const Icon(Icons.logout), // Logout icon
            onPressed: _logout, // Call logout function
            tooltip: "Logout", // Text shown on long press
          ),
          const SizedBox(width: 8), // Spacing for the right side of the app bar
        ],
      ),
      body: _isLoading // Conditional rendering based on loading state
          ? Center(
              // Display a customized loading indicator
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryRed), // Your primary red color
                    strokeWidth: 4, // Thicker stroke
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading your profile...',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _hasError // Conditional rendering for error state
              ? Center(
                  // Display an error message with an icon and a retry button
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: accentRed), // Error icon
                      const SizedBox(height: 20),
                      const Text(
                        'Failed to load user data.\nPlease check your connection or try again.',
                        style: TextStyle(
                          color: Colors.black54, // Darker text for readability
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      // Button to retry loading user data
                      ElevatedButton.icon(
                        onPressed: _loadUser, // Call _loadUser again on press
                        icon: const Icon(Icons.refresh), // Refresh icon
                        label: const Text('Retry'), // Button text
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed, // Use primary red for button
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  // Allows the content to scroll if it exceeds screen height
                  padding: const EdgeInsets.all(20), // Padding around the main content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align contents to the left
                    children: [
                      // Card widget to contain and beautifully display user profile details
                      Card(
                        elevation: 6, // Increased elevation for more prominent card
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // More rounded corners
                        child: Padding(
                          padding: const EdgeInsets.all(25), // Inner padding of the card
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Profile", // Title for the profile section
                                style: TextStyle(
                                  fontSize: 24, // Larger, more prominent title
                                  fontWeight: FontWeight.bold,
                                  color: primaryRed, // Use primary red for title
                                ),
                              ),
                              // A subtle divider for visual separation
                              const Divider(height: 30, thickness: 1.5, color: Colors.grey),
                              // Display each user detail using the reusable _buildDetailRow method with icons
                              _buildDetailRow(Icons.person, "Name", _name),
                              _buildDetailRow(Icons.phone, "Phone", _phone),
                              _buildDetailRow(Icons.school, "Field", _field),
                              _buildDetailRow(Icons.calendar_today, "Semester", _sem),
                              _buildDetailRow(Icons.location_city, "City", _city),
                              _buildDetailRow(Icons.directions_bus, "Bus No.", _bus),
                              _buildDetailRow(Icons.stop, "Bus Stop", _stop),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30), // Spacing after the profile card

                      // Row for the icon buttons
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space out the buttons
                          children: [
                            // "Tap to Scan Attendance" as an IconButton
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.qr_code_scanner, size: 70, color: primaryRed), // Larger QR icon
                                  onPressed: () {
                                    if (_name == "N/A" || _phone == "N/A" || _field == "N/A" || _sem == "N/A" || _stop == "N/A" || _city == "N/A" || _bus == "N/A") {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please ensure all profile data is loaded before scanning.")),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ScanPage(
                                          name: _name,
                                          phone: _phone,
                                          field: _field,
                                          sem: _sem,
                                          stop: _stop,
                                          city: _city,
                                          bus: _bus,
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: "Scan Attendance", // Tooltip for accessibility
                                ),
                                const Text(
                                  "Scan Attendance",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                            // "Contact Us" as an IconButton
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.person_pin, size: 70, color: primaryRed), // Contact icon (or Icons.perm_contact_calendar, etc.)
                                  onPressed: () => _showContactDialog(context),
                                  tooltip: "Contact Us",
                                ),
                                const Text(
                                  "Contact Us",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                            // You can add more icons/buttons here if needed
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Spacing at the bottom
                    ],
                  ),
                ),
    );
  }
}