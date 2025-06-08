import 'dart:io';

import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/auth/auth_service.dart';
import 'package:barmate/data/notifiers.dart';
import 'package:barmate/model/category_model.dart';
import 'package:barmate/model/collection_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/repositories/category_repository.dart';
import 'package:barmate/repositories/collection_repository.dart';
import 'package:barmate/repositories/ingredient_repository.dart';
import 'package:barmate/screens/user_screens/search_screen.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:barmate/constants.dart' as constatns;

class CreateIngredient extends StatefulWidget {
  const CreateIngredient({super.key});

  @override
  State<CreateIngredient> createState() => _CreateCollectionState();
}

class _CreateCollectionState extends State<CreateIngredient> {
  var logger = Logger(printer: PrettyPrinter());

  final _formKey = GlobalKey<FormState>();
  String? imagePath;

  final TextEditingController _ingredientNameController =
      TextEditingController();
  final TextEditingController _ingredientDescriptionController =
      TextEditingController();
  final TextEditingController _ingredientUnitController =
      TextEditingController();

  final IngredientRepository ingredientRepository = IngredientRepository();
  final CategoryRepository categoryRepository = CategoryRepository();
  List<Map<String, bool>> categories = [];
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Ingredient')),
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
                controller: _ingredientNameController,
                decoration: const InputDecoration(labelText: 'Ingredient Name'),
                maxLength: 40,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a ingredient name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ingredientDescriptionController,
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
              TextFormField(
                controller: _ingredientUnitController,
                decoration: const InputDecoration(labelText: 'Unit'),
                maxLines: 1,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category
              Row(
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _addCategory();
                    },
                    child: const Text('+ Add Category'),
                  ),
                ],
              ),
              categories.where((category) => category.values.first).isEmpty
                  ? const SizedBox.shrink()
                  : Wrap(
                    spacing: 8,
                    children:
                        categories
                            .where((category) => category.values.first)
                            .map((category) {
                              final categoryName = category.keys.first;
                              return FilterChip(
                                label: Text(
                                  categoryName,
                                  style: TextStyle(
                                    color:
                                        true
                                            ? Colors.white
                                            : Colors.black, // dynamiczny kolor
                                  ),
                                ),
                                selected: true,
                                selectedColor: Colors.deepPurple,
                                backgroundColor: Colors.grey[300],
                                onSelected: (_) {
                                  setState(() {
                                    category[categoryName] = false;
                                  });
                                },
                              );
                            })
                            .toList(),
                  ),
              const SizedBox(height: 24),
              // Submit button
              ElevatedButton(
                onPressed: () {
                  _addIngredient();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Submit Ingredient',
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

  Future<void> _loadCategories() async {
    logger.d('Fetching categories from API');

    final List<Category> fetchedCategories =
        await categoryRepository.getEveryCategory();

    final List<Map<String, dynamic>> categoriesMaps =
        fetchedCategories.map((i) => i.toMap()).toList();

    if (!mounted) return;
    setState(() {
      categories.addAll(
        fetchedCategories.map((category) => {category.name: false}),
      );
    });
  }

Future<void> _addCategory() async {
  List<Map<String, bool>> editedCategories =
      categories.map((c) => {c.keys.first: c.values.first}).toList();

  String? selectedCategory = editedCategories.firstWhere(
    (c) => c.values.first == true,
    orElse: () => <String, bool>{},
  ).keys.firstOrNull;

  final result = await showDialog<List<Map<String, bool>>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, categories),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select category:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8.0,
                    children: editedCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final categoryName = entry.value.keys.first;
                      final isSelected = selectedCategory == categoryName;

                      return ChoiceChip(
                        label: Text(
                          categoryName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.purple,
                        backgroundColor: Colors.grey[300],
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = isSelected ? null : categoryName;

                            editedCategories = editedCategories.map((c) {
                              final name = c.keys.first;
                              return {name: name == selectedCategory};
                            }).toList();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = null;
                            editedCategories = editedCategories.map((c) {
                              return {c.keys.first: false};
                            }).toList();
                          });
                          Navigator.pop(context, editedCategories);
                        },
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, editedCategories);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );

  if (result != null) {
    setState(() {
      categories = result;
    });
  }
}

Future<void> _addIngredient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (imagePath == null || imagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for the ingredient.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    selectedCategory = null;
    for (String category in categories
        .where((category) => category.values.first)
        .map((category) => category.keys.first)) {
      Category categoryModel = await categoryRepository.getTagByName(category);
      if (categoryModel != null) {
        selectedCategory = categoryModel;
      } else {
        logger.w('Tag not found: $category');
      }

    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category for the ingredient.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    logger.d(
      'Adding ingredient: ${_ingredientNameController.text}, '
      'Description: ${_ingredientDescriptionController.text}, '
      'Unit: ${_ingredientUnitController.text}, '
      'Category: ${selectedCategory!.id}, '
      'Image Path: $imagePath',
    );

    File imageFile = File(imagePath!);

    final result = ingredientRepository.createIngredient(
      _ingredientNameController.text,
      _ingredientUnitController.text,
      imageFile,
      selectedCategory!.id,
      _ingredientDescriptionController.text,
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
