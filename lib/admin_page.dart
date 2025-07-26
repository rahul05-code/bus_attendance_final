import 'package:flutter/material.dart';
import 'admin_attendance_page.dart';
import 'admin_user_management_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Portal", // Changed title to 'Admin Portal'
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700, // Slightly bolder for impact
            fontSize: 24, // Larger font size
            letterSpacing: 1.2, // Add some letter spacing
          ),
        ),
        backgroundColor: Colors.red[800], // A deeper, richer red
        elevation: 0, // No shadow for a flat, modern look
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50], // Very light grey solid background
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Text(
                      "Welcome, Administrator!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Effortlessly manage your organization's operations.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40), // More spacing before cards
                    _buildFeatureTile(
                      context,
                      icon: Icons.group_add_outlined, // More specific icon
                      title: "User Management",
                      description: "Create, update, and deactivate user accounts.",
                      color: const Color(0xFF1ABC9C), // Teal green
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminUserManagementPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureTile(
                      context,
                      icon: Icons.event_note_outlined, // Specific attendance icon
                      title: "Attendance Records",
                      description: "Access and review daily attendance logs.",
                      color: const Color(0xFF3498DB), // Sky blue
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminAttendancePage()),
                        );
                      },
                    ),
                    // You can add more feature tiles here
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        "© 2025 [Your Company Name]", // Footer for professionalism
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6, // Subtle elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        highlightColor: color.withOpacity(0.1), // Gentle highlight
        splashColor: color.withOpacity(0.2), // Gentle splash
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white, // Solid white background for the card
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5), // Subtle border
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color, // Use the primary color for the icon background
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 30, // Slightly larger icon size
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[850], // Darker text for titles
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16, // Slightly smaller arrow
              ),
            ],
          ),
        ),
      ),
    );
  }
}