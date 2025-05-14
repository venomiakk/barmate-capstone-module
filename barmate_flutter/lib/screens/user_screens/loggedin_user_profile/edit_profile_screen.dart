import 'package:flutter/material.dart';

import 'package:logger/logger.dart';

class EditProfileScreen extends StatefulWidget {
  final String? userTitle;
  final String? userBio;

  const EditProfileScreen({super.key, this.userTitle, this.userBio});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _logger = Logger(printer: PrettyPrinter());
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.userTitle ?? '';
    _bioController.text = widget.userBio ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "User Title: ${widget.userTitle}, User Bio: ${widget.userBio}",
        ),
      ),
    );
  }
}
