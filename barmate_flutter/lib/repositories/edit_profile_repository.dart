import 'dart:io';

import 'package:barmate/constants.dart' as constants;
import 'package:barmate/model/title_model.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileRepository {
  final SupabaseClient client = Supabase.instance.client;
  var logger = Logger(printer: PrettyPrinter());

  // create constructor
  EditProfileRepository() {
    // callUpdateProfileFunction();
  }

  String? getCurrentUserId() {
    final userId = client.auth.currentSession?.user.id;
    return userId;
  }

  Future<void> callUpdateProfileFunction() async {
    logger.d('Calling update profile function');
    final url = constants.updateProfileUrl;
    final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
    final anonKey = constants.supabaseAnonKey;
    logger.d("REPOSITORY: update profile");
    // final response = await http.post(
    //   Uri.parse(url),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Authorization': 'Bearer $jwt',
    //   },
    //   body: '{"msg": "from logged-in user"}',
    // );
    // if (response.statusCode == 200) {
    //   logger.d('Update profile function called successfully: ${response.body}');
    // } else {
    //   logger.e('Error calling update profile function: ${response.body}');
    // }
  }

  Future<List<TitleModel>> fetchAvailableTitles() async {
    try {
      final response = await client.rpc('get_all_titles', params: {});
      if (response != null) {
        // logger.d('Available titles fetched successfully: $response');
        return (response as List)
            .map((item) => TitleModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      logger.e('Error fetching available titles: $e');
    }
    return [];
  }

  Future<void> updateProfile(
    int? title,
    String? bio,
  ) async {
    try {
      await client.rpc(
        'update_profile',
        params: {
          'arg_bio': bio,
          'arg_title': title,
          'arg_userid': getCurrentUserId(),
        },
      );
    } catch (e) {
      logger.e('Error updating profile: $e');
    }
  }

  Future<void> uploadAndSetAvatar(File image) async {
    // TODO: to chya nie do konca dziala...
    // try {
    //   await client.storage.from('profilepics').remove([
    //     'avatars/${getCurrentUserId()}',
    //   ]);
    // } catch (e) {
    //   logger.e('File doesn\'t exist: $e');
    // }
    try {
      await client.storage
          .from('profilepics')
          .upload(
            'avatars/${getCurrentUserId()}',
            image,
            fileOptions: const FileOptions(upsert: true),
          );
    } catch (e) {
      logger.e('Error uploading image: $e');
    }

    try {
      await client.rpc(
        'update_user_avatar',
        params: {
          'arg_url': 'avatars/${getCurrentUserId()}',
          'arg_userid': getCurrentUserId(),
        },
      );
    } catch (e) {
      logger.e('Error updating profile with avatar: $e');
    }
  }
}
