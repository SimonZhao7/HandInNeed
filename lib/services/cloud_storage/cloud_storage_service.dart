// Firebase
import 'package:firebase_storage/firebase_storage.dart';
// Util
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
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

  Future<XFile> urlToXFile({required String url}) async {
    final res = await http.get(Uri.parse(url));
    final fileName = url.split('/').last;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(res.bodyBytes);
    return XFile.fromData(res.bodyBytes, path: file.path);
  }
}
