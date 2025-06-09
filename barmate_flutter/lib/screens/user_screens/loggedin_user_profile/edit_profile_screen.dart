import 'package:barmate/controllers/edit_profile_controller.dart';
import 'package:barmate/model/title_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart';

class EditProfileScreen extends StatefulWidget {
  final String? userTitle;
  final String? userBio;
  final String? userImageUrl;

  const EditProfileScreen({
    super.key,
    this.userTitle,
    this.userBio,
    this.userImageUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileController _controller = EditProfileController.create();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _logger = Logger(printer: PrettyPrinter());
  bool _isSaving = false;
  List<TitleModel> _availableTitles = [];
  File? _selectedImage;
  int? _selectedTitleId;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.userTitle ?? '';
    _bioController.text = widget.userBio ?? '';
    _loadAvailableTitles();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableTitles() async {
    try {
      _availableTitles = await _controller.fetchAvailableTitles();
      if (widget.userTitle != null && _availableTitles.isNotEmpty) {
        final matchingTitle = _availableTitles.firstWhere(
          (title) => title.title == widget.userTitle,
          orElse: () => _availableTitles.first,
        );
        setState(() {
          _selectedTitleId = matchingTitle.id;
        });
      }
      setState(() {});
    } catch (e) {
      _logger.e("Error loading available titles: $e");
    }
  }

  Future<void> _pickImage() async {
    // Kontynuuj wybieranie zdjęcia
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        // maxWidth: 1024, // Opcjonalne, aby zmniejszyć rozmiar zdjęcia
        // maxHeight: 1024,
        // imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _logger.e("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        // _logger.d("image: $_selectedImage");
        await _controller.updateProfile(
          _selectedTitleId,
          _bioController.text,
          _selectedImage,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Znajdź pełny obiekt wybranego tytułu
          String? selectedTitleText;
          if (_selectedTitleId != null) {
            final selectedTitle = _availableTitles.firstWhere(
              (title) => title.id == _selectedTitleId,
              orElse: () => TitleModel(id: _selectedTitleId!, title: ''),
            );
            selectedTitleText = selectedTitle.title;
          }

          // Zwróć aktualne dane zamiast wartości boolean
          Navigator.pop(context, {
            'title': selectedTitleText,
            'bio': _bioController.text,
            'imageChanged': _selectedImage != null,
          });
        }
      } catch (e) {
        _logger.e("Error saving profile: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error saving profile'),
              backgroundColor: Colors.deepOrange,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : widget.userImageUrl != null
                              ? NetworkImage(widget.userImageUrl!)
                              : null,
                      child:
                          (_selectedImage == null &&
                                  widget.userImageUrl == null)
                              ? const Icon(Icons.person, size: 60)
                              : null,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTitleId,
                hint: const Text('Choose a title'),
                isExpanded: true,
                items:
                    _availableTitles.map((titleObj) {
                      return DropdownMenuItem<int>(
                        value: titleObj.id, // Używamy id jako wartości
                        child: Text(titleObj.title), // Wyświetlamy tytuł
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTitleId = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Bio text field
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: const OutlineInputBorder(),
                  helperText: 'Max 40 characters',
                  counterText: '${_bioController.text.length}/40',
                ),
                maxLines: 3,
                maxLength: 40,
                validator: (value) {
                  if (value != null && value.length > 40) {
                    return 'Bio cannot exceed 40 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
