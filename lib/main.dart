import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
            .copyWith(secondary: Colors.amber), // Color de acento
      ),
      home: ContactListScreen(),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await DatabaseHelper.instance.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _addContact(String name, String phone, String email) async {
    final newContact = {
      'name': name,
      'phone': phone,
      'email': email,
    };
    await DatabaseHelper.instance.insertContact(newContact);
    _loadContacts();
  }

  Future<void> _updateContact(
      int id, String name, String phone, String email) async {
    final updatedContact = {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
    await DatabaseHelper.instance.updateContact(updatedContact);
    _loadContacts();
  }

  Future<void> _deleteContact(int id) async {
    await DatabaseHelper.instance.deleteContact(id);
    _loadContacts();
  }

  void _showContactDialog({Map<String, dynamic>? contact}) {
    final nameController = TextEditingController(text: contact?['name']);
    final phoneController = TextEditingController(text: contact?['phone']);
    final emailController = TextEditingController(text: contact?['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (contact == null) {
                  _addContact(
                    nameController.text,
                    phoneController.text,
                    emailController.text,
                  );
                } else {
                  _updateContact(
                    contact['id'],
                    nameController.text,
                    phoneController.text,
                    emailController.text,
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(contact == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: ListTile(
              title: Text(contact['name']),
              subtitle: Text('${contact['phone']} - ${contact['email']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showContactDialog(contact: contact),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteContact(contact['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
