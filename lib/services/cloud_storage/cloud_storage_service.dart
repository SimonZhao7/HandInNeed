// Firebase
import 'package:firebase_storage/firebase_storage.dart';
// Util
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class CloudStorageService {
  static final _shared = CloudStorageService._sharedInstance();
  CloudStorageService._sharedInstance();
  factory CloudStorageService() => _shared;

  final firebaseStorage = FirebaseStorage.instance.ref();

  Future<String> uploadImage({
    required XFile selectedPhoto,
    required String path,
  }) async {
    final file = File(selectedPhoto.path);
    final storageRef = firebaseStorage.child(
      '$path/${const Uuid().v4()}-${selectedPhoto.name}',
    );
    await storageRef.putFile(file);
    return await storageRef.getDownloadURL();
  }
}
