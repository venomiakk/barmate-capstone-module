import 'dart:io';

import 'package:barmate/Utils/user_shared_preferences.dart';
import 'package:barmate/constants.dart' as constatns;
import 'package:barmate/model/ingredient_model.dart';
import 'package:barmate/model/recipe_model.dart';
import 'package:barmate/model/tag_model.dart';
import 'package:barmate/repositories/recipe_repository.dart';
import 'package:barmate/repositories/tag_repository.dart';
import 'package:barmate/screens/user_screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache/flutter_cache.dart' as cache;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  var logger = Logger(printer: PrettyPrinter());

  final TextEditingController _drinkNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? imagePath;
  final List<Map<String, dynamic>> ingredients = [];
  final List<String> steps = [];
  List<Map<String, bool>> tags = [];
  final Set<TagModel> selectedTags = {};
  bool hasIce = false;
  int selectedStrength = 2;

  String userId = '';

  TagRepository tagRepository = TagRepository();
  RecipeRepository recipeRepository = RecipeRepository();

  void initState() {
    super.initState();
    _loadTags();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    final prefs = await UserPreferences.getInstance();
    userId = prefs.getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: const Text('Add From Camera'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Name & Description
              TextFormField(
                controller: _drinkNameController,
                decoration: const InputDecoration(labelText: 'Drink Name'),
                maxLength: 40,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a drink name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Ingredients
              Row(
                children: [
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _addIngredientDialog();
                    },
                    child: const Text('+ Add Ingredient'),
                  ),
                ],
              ),
              ...ingredients.map((ingredient) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading:
                        ingredient['photo_url'] != null
                            ? Image.network(
                              '${constatns.picsBucketUrl}/${ingredient['photo_url']}',
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
                            ingredient['name'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      ingredient['description'] ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            () {
                              return "${ingredient['amount']} ${ingredient['unit']}";
                            }(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final updatedIngredient =
                                await _showIngredientEditDialog(ingredient);
                            print(updatedIngredient);
                            if (updatedIngredient != null) {
                              setState(() {
                                final index = ingredients.indexOf(ingredient);
                                if (index != -1) {
                                  ingredients[index] = updatedIngredient;
                                }
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              ingredients.remove(ingredient);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),
              // Ice checkbox
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Image.asset(
                    'images/ice.jpg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ice',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'Add ice to the drink',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: Checkbox(
                    value: hasIce,
                    onChanged: (value) {
                      setState(() {
                        hasIce = value ?? false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Preparation steps
              Row(
                children: [
                  const Text(
                    'Preparation Steps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _addStepDialog();
                    },
                    child: const Text('+ Add Step'),
                  ),
                ],
              ),
              ...steps.asMap().entries.map((entry) {
                int idx = entry.key;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${idx + 1}')),
                    title: Text(entry.value ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result = await _editStepDialog(entry.value);

                            setState(() {
                              if (result != null) {
                                steps[idx] = result;
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              steps.removeAt(idx);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Tags
              Row(
                children: [
                  const Text(
                    'Tags',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _addTags();
                    },
                    child: const Text('+ Add Tags'),
                  ),
                ],
              ),
              tags.where((tag) => tag.values.first).isEmpty
                  ? const SizedBox.shrink()
                  : Wrap(
                    spacing: 8,
                    children:
                        tags.where((tag) => tag.values.first).map((tag) {
                          final tagName = tag.keys.first;
                          return FilterChip(
                            label: Text(
                              tagName,
                              // style: TextStyle(
                              //   color:
                              //       true
                              //           ? Colors.white
                              //           : Colors.black, // dynamiczny kolor
                              // ),
                            ),
                            selected: true,
                            // selectedColor: Colors.deepPurple,
                            // backgroundColor: Colors.grey[300],
                            onSelected: (_) {
                              setState(() {
                                tag[tagName] = false;
                              });
                            },
                          );
                        }).toList(),
                  ),
              const SizedBox(height: 24),
              // Strength selection
              const Text(
                'Strength',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Icon(Icons.local_bar),
                    labelStyle: TextStyle(
                      color:
                          selectedStrength == 1 ? Colors.white : Colors.black,
                    ),
                    selected: selectedStrength == 1,
                    selectedColor: Colors.green[400],
                    onSelected: (_) {
                      setState(() {
                        selectedStrength = 1;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Icon(Icons.local_bar_outlined),
                    labelStyle: TextStyle(
                      color:
                          selectedStrength == 2 ? Colors.white : Colors.black,
                    ),
                    selected: selectedStrength == 2,
                    selectedColor: Colors.deepOrange[400],
                    onSelected: (_) {
                      setState(() {
                        selectedStrength = 2;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Icon(Icons.local_drink),
                    labelStyle: TextStyle(
                      color:
                          selectedStrength == 3 ? Colors.white : Colors.black,
                    ),
                    selected: selectedStrength == 3,
                    selectedColor: Colors.pink[500],
                    onSelected: (_) {
                      setState(() {
                        selectedStrength = 3;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Submit button
              ElevatedButton(
                onPressed: () {
                  _addRecipe();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Submit Recipe',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addIngredientDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(isFromAddRecipe: true),
      ),
    );

    logger.d(result);
    if (result != null) {
      setState(() {
        ingredients.add({
          'id': result['ingredient'].id,
          'name': result['ingredient'].name,
          'amount': result['amount'],
          'unit': result['ingredient'].unit,
          'photo_url': result['ingredient'].photo_url,
          'description': result['ingredient'].description,
        });
      });
    }
  }

  void _addStepDialog() {
    String step = '';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              content: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: SizedBox(
                      width:
                          MediaQuery.of(context).size.width *
                          0.9, // maksymalna szerokość
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Add Step',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            maxLines: 5,
                            maxLength: 200,
                            decoration: const InputDecoration(
                              hintText: 'Step description',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => step = val,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (step.trim().isNotEmpty) {
                                this.setState(() {
                                  steps.add(step.trim());
                                });
                              }
                              Navigator.of(context).pop();
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  Future<void> _loadTags() async {
    final cached = await cache.load('tags', null);

    if (cached != null && cached is List) {
      logger.d('Loaded tags from cache');
      final List<TagModel> cachedTags =
          cached.map<TagModel>((item) => TagModel.fromMap(item)).toList();

      setState(() {
        tags.addAll(cachedTags.map((tag) => {tag.name: false}));
      });
    } else {
      logger.d('Fetching tags from API');

      final List<TagModel> fetchedTags = await tagRepository.getEveryTag();

      final List<Map<String, dynamic>> tagMaps =
          fetchedTags.map((i) => i.toMap()).toList();

      cache.remember('tags', tagMaps, 86400);
      cache.write('tags', tagMaps, 86400);

      setState(() {
        tags.addAll(fetchedTags.map((tag) => {tag.name: false}));
      });
    }
  }

  Future<void> _addTags() async {
    // Tworzymy kopię listy tagów
    List<Map<String, bool>> editedTags =
        tags.map((tag) => {tag.keys.first: tag.values.first}).toList();

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
                      onPressed: () => Navigator.pop(context, tags), // oryginał
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select tags:',
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
                      children:
                          editedTags.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tag = entry.value;
                            final tagName = tag.keys.first;
                            final isSelected = tag[tagName] as bool;

                            return ChoiceChip(
                              label: Text(
                                tagName,
                                style: TextStyle(
                                  // color:
                                  //     isSelected
                                  //         ? Colors.white
                                  //         : Colors
                                  //             .black, // dynamiczny kolor tekstu
                                ),
                              ),
                              selected: isSelected,
                              // selectedColor:
                              //     Colors.purple, // kolor tła po zaznaczeniu
                              // backgroundColor:
                              //     Colors
                              //         .grey[300], // kolor tła gdy niezaznaczone
                              onSelected: (selected) {
                                setState(() {
                                  editedTags[index] = {tagName: selected};
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
                            editedTags =
                                editedTags
                                    .map((tag) => {tag.keys.first: false})
                                    .toList();
                            Navigator.pop(context, editedTags);
                          },
                          child: const Text('Clear'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, editedTags);
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
        tags = result;
      });
    }
  }

  Future<Map<String, dynamic>?> _showIngredientEditDialog(
    Map<String, dynamic> ingredient,
  ) async {
    int counter = ingredient['amount'];

    List<int> defaultValues =
        ingredient['unit'] == 'ml'
            ? [10, 20, 40, 50, 60, 100]
            : ingredient['unit'] == 'g'
            ? [1, 2, 5, 10, 15, 20]
            : [1, 2, 3, 4, 6, 8];

    TextEditingController controller = TextEditingController(
      text: counter.toString(),
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width:
                          ingredient['unit'] == 'ml'
                              ? 350
                              : ingredient['unit'] == 'leaves'
                              ? 400
                              : 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Amount (${ingredient['unit']})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter amount',
                            ),
                            onChanged: (value) {
                              setState(() {
                                counter = int.tryParse(value) ?? counter;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children:
                                defaultValues.map((value) {
                                  return ChoiceChip(
                                    label: Text('$value ${ingredient['unit']}'),
                                    selected: counter == value,
                                    onSelected: (_) {
                                      setState(() {
                                        counter = value;
                                        controller.text = value.toString();
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              ingredient['amount'] = counter;
                              Navigator.of(context).pop(ingredient);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    return result;
  }

  Future<String?> _editStepDialog(String initialValue) async {
    TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    return await showDialog<String>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              content: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Edit Step',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: controller,
                            maxLines: 5,
                            maxLength: 200,
                            decoration: const InputDecoration(
                              hintText: 'Step description',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final step = controller.text.trim();
                              if (step.isNotEmpty) {
                                Navigator.pop(context, step);
                              } else {
                                Navigator.pop(context); // null
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingredient list cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Steps list cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    selectedTags.clear();
    for (String tag in tags
        .where((tag) => tag.values.first)
        .map((tag) => tag.keys.first)) {
      TagModel tagModel = await tagRepository.getTagByName(tag);
      if (tagModel != null) {
        selectedTags.add(tagModel);
      } else {
        logger.w('Tag not found: $tag');
      }
    }

    if (selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one tag.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    logger.d(
      'Adding recipe with the following data:'
      '\nName: ${_drinkNameController.text}'
      '\nDescription: ${_descriptionController.text}'
      '\nImage: $imagePath'
      '\nIngredients: $ingredients'
      '\nSteps: $steps'
      '\nHas Ice: $hasIce'
      '\nStrength: $selectedStrength'
      '\nTags: ${selectedTags.map((tag) => tag.name).join(', ')}',
    );

    File? imageFile = imagePath != null ? File(imagePath!) : null;

    final result = recipeRepository.addRecipe(
      _drinkNameController.text,
      _descriptionController.text,
      imageFile,
      userId,
      ingredients,
      steps,
      hasIce,
      selectedStrength,
      selectedTags.toList(),
    );

    if (await result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Close the screen after adding the recipe
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
