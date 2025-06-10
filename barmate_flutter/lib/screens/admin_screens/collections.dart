import 'package:barmate/constants.dart' as constants;
import 'package:barmate/model/collection_model.dart';
import 'package:barmate/repositories/collection_repository.dart';
import 'package:barmate/screens/admin_screens/create_collection.dart';
import 'package:barmate/screens/user_screens/collection_screen.dart';
import 'package:barmate/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class Collections extends StatefulWidget {
  const Collections({super.key});

  @override
  State<Collections> createState() => _AddIngredientState();
}

class _AddIngredientState extends State<Collections> {
  var logger = Logger(printer: PrettyPrinter());

  CollectionRepository collectionRepository = CollectionRepository();

  List<Collection> collections = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _loadCollections();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Collections')),
    body: Center(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildGrid(),
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateCollection()),
        );
        await _loadCollections();
      },
      child: const Icon(Icons.add),
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
  );
}

  GridView _buildGrid() {
    return GridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.6,
      children: List.generate(collections.length, (index) {
        return _buildCard(collections[index]);
      }),
    );
  }

  Widget _buildCard(collection) {
    return InkWell(
      onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CollectionScreen(
                    collection: collection,
                  ),
            ),
          );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            _buildImage(collection.photoUrl),
            const SizedBox(width: 16),
            _buildInfo(collection),
            const SizedBox(width: 8),
            _buildActions(collection),
          ],
        ),
      ),
    );
  }

   _buildImage(imageUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              (imageUrl?.isNotEmpty ?? false)
                  ? Image.network(
                    '${constants.picsBucketUrl}/${imageUrl!}',
                    width: 104,
                    height: 104,
                    fit: BoxFit.cover,
                  )
                  : Image.asset(
                    'images/unavailable-image.jpg',
                    width: 104,
                    height: 104,
                    fit: BoxFit.cover,
                  ),
        ),
        _buildImageGradientOverlay(),
      ],
    );
   }
  
  _buildInfo(collection) {
    var name = collection.name ?? 'No Name';
    var description = collection.description ?? 'No Description';
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  _buildActions(collection) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.delete, size: 30),
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Collection'),
                  content: const Text('Are you sure you want to delete this collection?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await collectionRepository.deleteCollection(collection);
                  await _loadCollections();
                } catch (e) {
                  logger.e('Error deleting collection: $e');
                }
              }
            },
          ),
        ],
      );
  }

  Positioned _buildImageGradientOverlay() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 40,
        height: 104,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.25),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.75),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
  
  Future<void> _loadCollections() async {
  try {
    final value = await collectionRepository.getCollections();
    if (!mounted) return;
    setState(() {
      collections = value;
    });
  } catch (error) {
    logger.e('Error loading collections: $error');
  }
}

}