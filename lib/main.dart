import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const DCSCApp());
}

class DCSCApp extends StatelessWidget {
  const DCSCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DCSC App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005088),
          primary: const Color(0xFF005088),
          secondary: const Color(0xFF11CAA0),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  final String _adminPin = "1234"; // Default Admin PIN

  // Mock initial data with Live DB fallback
  List<Map<String, String>> _events = [
    {
      "title": "Annual Science Fair 2026",
      "date": "25 March, 2026",
      "desc": "Join us for the biggest science fair at Dhaka College campus."
    },
    {
      "title": "Astronomy & Stargazing Workshop",
      "date": "10 April, 2026",
      "desc": "Learn telescope handling and observation techniques."
    },
  ];

  List<Map<String, String>> _members = [
    {"name": "MD Abdullah", "role": "President", "dept": "Physics"},
    {"name": "Tanvir Ahmed", "role": "General Secretary", "dept": "Chemistry"},
    {"name": "Sajid Hasan", "role": "Treasurer", "dept": "Math"},
  ];

  void _loginAdmin() {
    TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Admin Access"),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Enter 4-digit PIN",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == _adminPin) {
                setState(() {
                  _isAdmin = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Admin mode enabled!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect PIN!")),
                );
              }
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  void _addEventDialog() {
    TextEditingController titleCtrl = TextEditingController();
    TextEditingController dateCtrl = TextEditingController();
    TextEditingController descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Event"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Event Title"),
              ),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(labelText: "Date (e.g. 12 May)"),
              ),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Description"),
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
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                setState(() {
                  _events.add({
                    "title": titleCtrl.text,
                    "date": dateCtrl.text,
                    "desc": descCtrl.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add Event"),
          )
        ],
      ),
    );
  }

  void _addMemberDialog() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController roleCtrl = TextEditingController();
    TextEditingController deptCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Executive Member"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Member Name"),
              ),
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(labelText: "Role/Designation"),
              ),
              TextField(
                controller: deptCtrl,
                decoration: const InputDecoration(labelText: "Department"),
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
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _members.add({
                    "name": nameCtrl.text,
                    "role": roleCtrl.text,
                    "dept": deptCtrl.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add Member"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildHomeView(),
      _buildEventsView(),
      _buildCommitteeView(),
      _buildContactView(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF005088),
        foregroundColor: Colors.white,
        title: const Text(
          "Dhaka College Science Club",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isAdmin ? Icons.admin_panel_settings : Icons.lock_outline),
            tooltip: _isAdmin ? "Admin Active" : "Admin Login",
            onPressed: _isAdmin
                ? () {
                    setState(() => _isAdmin = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Admin logged out")),
                    );
                  }
                : _loginAdmin,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.event), label: "Events"),
          NavigationDestination(icon: Icon(Icons.group), label: "Committee"),
          NavigationDestination(icon: Icon(Icons.contact_support), label: "Contact"),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_selectedIndex == 1) _addEventDialog();
                if (_selectedIndex == 2) _addMemberDialog();
              },
              backgroundColor: const Color(0xFF11CAA0),
              icon: const Icon(Icons.add),
              label: Text(_selectedIndex == 1 ? "Add Event" : "Add Member"),
            )
          : null,
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF005088), Color(0xFF0073B7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.science, color: Colors.white, size: 48),
                SizedBox(height: 10),
                Text(
                  "Welcome to DCSC",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Promoting science, innovation, and research at Dhaka College.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Recent Highlights",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.campaign, color: Color(0xFF005088)),
              title: Text("Science Fair Registration Open!"),
              subtitle: Text("Submit your projects before March 20."),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, idx) {
        final ev = _events[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(ev["title"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date: ${ev['date']}", style: const TextStyle(color: Color(0xFF005088))),
                Text(ev["desc"] ?? ""),
              ],
            ),
            trailing: _isAdmin
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => _events.removeAt(idx));
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildCommitteeView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, idx) {
        final m = _members[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF005088),
              child: Text(m["name"]![0], style: const TextStyle(color: Colors.white)),
            ),
            title: Text(m["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${m['role']} - ${m['dept']}"),
            trailing: _isAdmin
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => _members.removeAt(idx));
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildContactView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Contact Info", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Divider(),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.location_on, color: Color(0xFF005088)),
            title: Text("Dhaka College Campus"),
            subtitle: Text("Mirpur Rd, Dhaka 1205"),
          ),
          ListTile(
            leading: Icon(Icons.email, color: Color(0xFF005088)),
            title: Text("Email Us"),
            subtitle: Text("contact@dcsc.org"),
          ),
          ListTile(
            leading: Icon(Icons.facebook, color: Color(0xFF005088)),
            title: Text("Facebook Page"),
            subtitle: Text("facebook.com/dcsc.official"),
          ),
        ],
      ),
    );
  }
}
