// lib/admin_dashboard/admin_user_form_page.dart

import 'package:flutter/material.dart';
import 'package:denpasar_food_mobile/models/local_user.dart';
import 'package:denpasar_food_mobile/services/local_storage_service.dart';

class AdminUserFormPage extends StatefulWidget {
  final LocalUser? user;

  const AdminUserFormPage({super.key, this.user});

  @override
  _AdminUserFormPageState createState() => _AdminUserFormPageState();
}

class _AdminUserFormPageState extends State<AdminUserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isActive = false;
  bool _isSuperuser = false;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _emailController.text = widget.user!.email;
      _isActive = widget.user!.isActive;
      _isSuperuser = widget.user!.isSuperuser;
    }
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      if (widget.user == null && _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password is required for new users.')),
        );
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
        return;
      }

      final newUser = LocalUser(
        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch,
        username: _usernameController.text,
        email: _emailController.text,
        isActive: _isActive,
        isSuperuser: _isSuperuser,
      );

      List<LocalUser> existingUsers = await _localStorageService.getUsers();
      if (widget.user == null) {
        existingUsers.add(newUser);
      } else {
        existingUsers = existingUsers.map((user) {
          return user.id == newUser.id ? newUser : user;
        }).toList();
      }
      await _localStorageService.saveUsers(existingUsers);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email';
                  }
                  return null;
                },
              ),
              if (widget.user == null)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password *'),
                  obscureText: true,
                  validator: (value) {
                    if (widget.user == null &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter the password';
                    }
                    return null;
                  },
                ),
              if (widget.user == null)
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password *'),
                  obscureText: true,
                  validator: (value) {
                    if (widget.user == null &&
                        (value == null || value.isEmpty)) {
                      return 'Please confirm the password';
                    }
                    return null;
                  },
                ),
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (bool? value) {
                      setState(() {
                        _isActive = value ?? false;
                      });
                    },
                  ),
                  const Text('Active'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isSuperuser,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSuperuser = value ?? false;
                      });
                    },
                  ),
                  const Text('Admin'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _saveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.user == null ? Colors.green : Colors.yellow,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.user == null ? 'Add' : 'Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
