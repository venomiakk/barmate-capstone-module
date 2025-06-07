import 'dart:io';

import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/data/notifiers.dart';
import 'package:barmate/model/collection_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/repositories/collection_repository.dart';
import 'package:barmate/screens/user_screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:barmate/constants.dart' as constatns;

class CreateCollection extends StatefulWidget {
  const CreateCollection({super.key});

  @override
  State<CreateCollection> createState() => _CreateCollectionState();
}

class _CreateCollectionState extends State<CreateCollection> {
  var logger = Logger(printer: PrettyPrinter());

  final _formKey = GlobalKey<FormState>();
  String? imagePath;

  final TextEditingController _collectionNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<Recipe> recipes = [];

  final CollectionRepository collectionRepository = CollectionRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Collection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image:
                      imagePath != null
                          ? DecorationImage(
                            image: FileImage(File(imagePath!)),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text('Add From Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Name & Description
              TextFormField(
                controller: _collectionNameController,
                decoration: const InputDecoration(labelText: 'Collection Name'),
                maxLength: 40,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a collection name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                maxLength: 400,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //Recipes
              Row(
                children: [
                  const Text(
                    'Recipes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _addRecipesDialog();
                    },
                    child: const Text('+ Add Recipe'),
                  ),
                ],
              ),
              ...recipes.map((recipe) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading:
                        recipe.photoUrl != null
                            ? Image.network(
                              '${constatns.picsBucketUrl}/${recipe.photoUrl}',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'images/unavailable-image.jpg',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      recipe.description ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              recipes.remove(recipe);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              // Strength selection
              const Text(
                'End date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Select end date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: _endDateController,
                readOnly: true,
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    _endDateController.text =
                        '${selectedDate.toLocal()}'.split(' ')[0];
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }

                  try {
                    DateTime selected = DateTime.parse(value);
                    DateTime now = DateTime.now();
                    DateTime today = DateTime(now.year, now.month, now.day);

                    if (selected.isBefore(today)) {
                      return 'End date cannot be in the past';
                    }
                  } catch (e) {
                    return 'Invalid date format';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Submit button
              ElevatedButton(
                onPressed: () {
                  _addCollection();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Submit Collection',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  void _addRecipesDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(isFromAddCollection: true),
      ),
    );

    logger.d(result);
    if (result != null) {
      setState(() {
        recipes.add(result['recipe']);
      });
    }
    logger.d(recipes);
  }

  Future<void> _addCollection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingredient list cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    logger.d(
      'Adding collection with name: ${_collectionNameController.text}'
      ', description: ${_descriptionController.text}, imagePath: $imagePath, recipes: $recipes, endDate: ${_endDateController.text}',
    );

    File? imageFile = imagePath != null ? File(imagePath!) : null;
    DateTime? endDate = _endDateController.text.isNotEmpty
        ? DateTime.tryParse(_endDateController.text)
        : null;

    final result = collectionRepository.createCollection(
      _collectionNameController.text,
      _descriptionController.text,
      imageFile,
      endDate,
      recipes,
    );

    if (await result){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add recipe. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
