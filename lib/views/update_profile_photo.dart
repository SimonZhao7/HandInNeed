import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:image_picker/image_picker.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
// Util
import 'dart:io';

class UpdateProfilePhotoView extends StatefulWidget {
  const UpdateProfilePhotoView({super.key});

  @override
  State<UpdateProfilePhotoView> createState() => _UpdateProfilePhotoViewState();
}

class _UpdateProfilePhotoViewState extends State<UpdateProfilePhotoView> {
  final _authService = AuthService();
  XFile? _selectedPhoto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile Photo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() {
                            _selectedPhoto = image;
                          });
                        }
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(200),
                        ),
                        child: _selectedPhoto != null
                            ? Image.file(
                                File(_selectedPhoto!.path),
                                fit: BoxFit.cover,
                              )
                            : FutureBuilder(
                                future: _authService.currentUser(),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.done:
                                      final user = snapshot.data!;
                                      return Image.network(
                                        user.displayImage,
                                        fit: BoxFit.cover,
                                      );
                                    default:
                                      return Container(
                                        color: const Color(lightGray),
                                      );
                                  }
                                },
                              ),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.edit,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Button(
              onPressed: () async {
                try {
                  _authService
                      .updateProfilePhoto(
                        photo: _selectedPhoto,
                      )
                      .then((_) => Navigator.of(context).pop())
                      .catchError(
                        (_) => showErrorSnackbar(
                          context,
                          'No new profile photo provided',
                        ),
                      );
                } catch (e) {
                  showErrorSnackbar(context, 'Something went wrong');
                }
              },
              label: 'Update Profile Photo',
            ),
          ],
        ),
      ),
    );
  }
}
