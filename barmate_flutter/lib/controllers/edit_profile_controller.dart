import 'dart:io';

import 'package:barmate/model/title_model.dart';
import 'package:barmate/repositories/edit_profile_repository.dart';
import 'package:logger/logger.dart';

class EditProfileController {
  final logger = Logger(printer: PrettyPrinter());
  final EditProfileRepository editProfileRepository = EditProfileRepository();

  // Fabryka do tworzenia instancji
  static EditProfileController Function() factory =
      () => EditProfileController();

  // Metoda fabryczna
  static EditProfileController create() {
    return factory();
  }

  Future<List<TitleModel>> fetchAvailableTitles() async {
    try {
      final titles = await editProfileRepository.fetchAvailableTitles();
      return titles;
    } catch (e) {
      logger.w("Error fetching available titles: $e");
      return [];
    }
  }

  Future<void> updateProfile(
    int? title,
    String? bio,
    File? image,
  ) async {
    if (image != null) {
      await editProfileRepository.uploadAndSetAvatar(image);
    }
    try {
      await editProfileRepository.updateProfile(title, bio);
    } catch (e) {
      logger.e("Error updating profile: $e");
    }
  }
}
