import 'package:flutter/material.dart';

class SearchFilterScreen extends StatefulWidget {
  final List<Map<String, bool>> filters;
  final List<Map<String, bool>> categories;
  final List<Map<String, bool>> tags;

  const SearchFilterScreen({
    required this.filters,
    required this.categories,
    required this.tags,
    super.key,
  });

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late List<Map<String, bool>> filters;
  late List<Map<String, bool>> categories;
  late List<Map<String, bool>> tags;

  @override
  void initState() {
    super.initState();

    if (widget.filters.every((filter) => filter.values.first)) {
      filters =
        widget.filters.map((filter) => {filter.keys.first: false}).toList();
    } else {
      filters = widget.filters
          .map((filter) => {filter.keys.first: filter.values.first})
          .toList();
    }
    
    if (widget.categories.every((category) => category.values.first)) {
      categories =
        widget.categories.map((category) => {category.keys.first: false}).toList();
    } else {
      categories = widget.categories
          .map((category) => {category.keys.first: category.values.first})
          .toList();
    }

    if (widget.tags.every((tag) => tag.values.first)) {
      tags =
        widget.tags.map((tag) => {tag.keys.first: false}).toList();
    } else {
      tags = widget.tags
          .map((tag) => {tag.keys.first: tag.values.first})
          .toList();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Filters',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Select categories:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              children:
                  filters.map((filter) {
                    return ChoiceChip(
                      label: Text(filter.keys.first),
                      selected: filter.values.first,
                      onSelected: (selected) {
                        setState(() {
                          filter[filter.keys.first] = selected;
                          if (filter.keys.first == 'Ingredients' && !(selected)) {
                            for (var category in categories) {
                              category[category.keys.first] = false;
                            }
                          }
                          if (filter.keys.first == 'Recipes' && !(selected)) {
                            for (var tag in tags) {
                              tag[tag.keys.first] = false;
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            if(filters[0].values.first)...[
            const SizedBox(height: 8),
            const Text(
              'Select ingredients categories:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              children:
                  categories.map((category) {
                    return ChoiceChip(
                      label: Text(category.keys.first),
                      selected: category.values.first,
                      onSelected: (selected) {
                        setState(() {
                          category[category.keys.first] = selected;
                        });
                      },
                    );
                  }).toList(),
            ),
            ],
            if(filters[1].values.first)...[
            const SizedBox(height: 8),
            const Text('Select tags:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              children:
                  tags.map((tag) {
                    return ChoiceChip(
                      label: Text(tag.keys.first),
                      selected: tag.values.first,
                      onSelected: (selected) {
                        setState(() {
                          tag[tag.keys.first] = selected;
                        });
                      },
                    );
                  }).toList(),
            ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (var filter in filters) {
                        filter[filter.keys.first] = false;
                      }
                      for (var category in categories) {
                        category[category.keys.first] = false;
                      }
                      for (var tag in tags) {
                        tag[tag.keys.first] = false;
                      }
                    });
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (filters.any((filter) => filter.values.first)) {
                        for (var filter in widget.filters) {
                          filter[filter.keys.first] =
                              filters
                                  .firstWhere(
                                    (f) => f.keys.first == filter.keys.first,
                                  )
                                  .values
                                  .first;
                        }
                      } else {
                        for (var filter in widget.filters) {
                          filter[filter.keys.first] = true;
                        }
                      }
                      if (categories.any((category) => category.values.first)) {
                        for (var category in widget.categories) {
                          category[category.keys.first] =
                              categories
                                  .firstWhere(
                                    (c) => c.keys.first == category.keys.first,
                                  )
                                  .values
                                  .first;
                        }
                      } else {
                        for (var category in widget.categories) {
                          category[category.keys.first] = true;
                        }
                      }
                      if (tags.any((tag) => tag.values.first)) {
                        for (var tag in widget.tags) {
                          tag[tag.keys.first] =
                              tags
                                  .firstWhere(
                                    (t) => t.keys.first == tag.keys.first,
                                  )
                                  .values
                                  .first;
                        }
                      } else {
                        for (var tag in widget.tags) {
                          tag[tag.keys.first] = true;
                        }
                      }
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
