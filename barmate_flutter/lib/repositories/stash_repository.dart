import 'package:barmate/controllers/notifications_controller.dart';
import 'package:barmate/model/stash_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserStashRepository {
  final SupabaseClient client = Supabase.instance.client;
  final logger = Logger(printer: PrettyPrinter());

  Future<List<UserStash>> fetchUserStash(var userId) async {
    try {
      print(userId);
      final response = await client.rpc(
        'get_user_stash',
        params: {'p_user_id': userId},
      );
      // logger.t('Response from get_user_stash: $response');
      if (response != null) {
        return (response as List).map((e) => UserStash.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching user stash: $e');
    }
    return [];
  }

  Future<void> addToStash(var userId, int ingredientId, int quantity) async {
    try {
      final response = await client.rpc(
        'add_to_stash',
        params: {
          'p_user_id': userId,
          'p_ingredient_id': ingredientId,
          'p_quantity': quantity,
        },
      );
      if (response != null) {
        print('Added to stash: $response');
      }
    } catch (e) {
      print('Error adding to stash: $e');
    }
  }

  Future<void> removeFromStash(
    String userId,
    int ingredientId, {
    BuildContext? context,
    String? ingredientName,
    String? unit,
  }) async {
    await Supabase.instance.client
        .from('user_stash')
        .delete()
        .match({
          'user_id': userId,
          'ingredient_id': ingredientId,
        });

    if (context != null && ingredientName != null && unit != null) {
      Provider.of<NotificationService>(context, listen: false)
          .maybeNotifyLowQuantity(
        ingredientName: ingredientName,
        amount: 0,
        unit: unit,
      );
    }
  }


  Future<void> changeIngredientAmount(
    String userId,
    int ingredientId,
    int newAmount, {
    BuildContext? context,
    String? ingredientName,
    String? unit,
  }) async {
    await Supabase.instance.client
        .from('user_stash')
        .update({'amount': newAmount})
        .match({
          'user_id': userId,
          'ingredient_id': ingredientId,
        });

    if (context != null && ingredientName != null && unit != null) {
      Provider.of<NotificationService>(context, listen: false)
          .maybeNotifyLowQuantity(
        ingredientName: ingredientName,
        amount: newAmount,
        unit: unit,
      );
    }
  }



  Future<UserStash?> fetchSingleIngredientFromStash(
    var userId,
    int ingredientId,
  ) async {
    try {
      final stash = await fetchUserStash(userId);
      return stash.firstWhere(
        (element) => element.ingredientId == ingredientId,
      );
    } catch (e) {
      print('Error fetching single stash item: $e');
      return null;
    }
  }
}
