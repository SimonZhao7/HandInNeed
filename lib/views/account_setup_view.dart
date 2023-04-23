import 'dart:io';
import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_exceptions.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
import 'package:hand_in_need/services/cloud_storage/cloud_storage_service.dart';
// Widgets
import '../widgets/button.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
import '../constants/route_names.dart';
// Util
import 'package:image_picker/image_picker.dart';


class AccountSetupView extends StatefulWidget {
  const AccountSetupView({super.key});

  @override
  State<AccountSetupView> createState() => _AccountSetupViewState();
}

class _AccountSetupViewState extends State<AccountSetupView> {
  final _authService = AuthService();
  final _googleStorageService = CloudStorageService();
  late TextEditingController _email;
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _userName;
  late TextEditingController _description;
  bool noEmail = true;
  XFile? image;

  @override
  void initState() {
    _email = TextEditingController();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _userName = TextEditingController();
    _description = TextEditingController();

    final userDetails = _authService.userDetails;
    if (userDetails.email != null) {
      _email.text = userDetails.email!;
      noEmail = false;
    }
    if (userDetails.displayName != null) {
      final formattedName = userDetails.displayName!.split(' ');
      _firstName.text = formattedName[0];
      _lastName.text = formattedName[1];
    }
    if (userDetails.photoURL != null) {
      _googleStorageService.urlToXFile(url: userDetails.photoURL!).then(
            (file) => {
              setState(() {
                image = file;
              })
            },
          );
    }
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _userName.dispose();
    _description.dispose();
    super.dispose();
  }

  void handleAccountCreation() async {
    final email = _email.text;
    final firstName = _firstName.text;
    final lastName = _lastName.text;
    final userName = _userName.text;
    final description = _description.text;
    final focus = FocusScope.of(context);
    final navigator = Navigator.of(context);

    if (!focus.hasPrimaryFocus) {
      focus.unfocus();
    }

    try {
      await _authService.finishAccountSetup(
        email: email,
        firstName: firstName,
        lastName: lastName,
        userName: userName,
        description: description,
        image: image,
      );
      navigator.pushNamedAndRemoveUntil(home, (_) => false);
    } catch (e) {
      if (e is NoEmailProvidedAuthException) {
        showErrorSnackbar(context, 'No email provided');
      } else if (e is NoUserNameProvidedAuthException) {
        showErrorSnackbar(context, 'No username provided');
      } else if (e is UserNameTooShortAuthException) {
        showErrorSnackbar(
          context,
          'Username must be at least 8 characters long',
        );
      } else if (e is UserNameAlreadyExistsAuthException) {
        showErrorSnackbar(
          context,
          'A user already exists with the provided username',
        );
      } else if (e is NoFirstNameProvidedAuthException) {
        showErrorSnackbar(context, 'No first name provided');
      } else if (e is NoLastNameProvidedAuthException) {
        showErrorSnackbar(context, 'No last name provided');
        return;
      } else if (e is NoProfilePictureProvidedAuthException) {
        showErrorSnackbar(context, 'No profile picture provided');
      } else if (e is InvalidEmailAuthException) {
        showErrorSnackbar(context, 'The email provided is invalid');
      } else if (e is EmailAlreadyInUseAuthException) {
        showErrorSnackbar(
          context,
          'A user already exists with the provided email',
        );
      } else {
        showErrorSnackbar(context, 'Something went wrong');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(primary)),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Text(
            'One more step...',
            style: Theme.of(context).textTheme.headline1,
          ),
          const SizedBox(height: 50),
          Text(
            'Please finish setting up your account',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 40),
          Text(
            'Email',
            style: labelStyle,
          ),
          Input(
            controller: _email,
            hint: 'E.g. johndoe@gmail.com',
            enabled: noEmail,
          ),
          const SizedBox(height: 5),
          Text(
            'Username',
            style: labelStyle,
          ),
          Input(
            controller: _userName,
            hint: 'E.g. JohnDoe1',
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'First Name',
                      style: labelStyle,
                    ),
                    Input(
                      controller: _firstName,
                      hint: 'E.g. John',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Name',
                      style: labelStyle,
                    ),
                    Input(
                      controller: _lastName,
                      hint: 'E.g. Doe',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (image != null) ...[
            Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.file(File(image!.path), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
          Button(
            onPressed: () async {
              final selectedImage = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                requestFullMetadata: false,
              );

              if (selectedImage == null) return;

              setState(() {
                image = selectedImage;
              });
            },
            label: '${image == null ? 'Select' : 'Change'} Profile Picture',
          ),
          const SizedBox(height: 10),
          Text(
            'Description',
            style: labelStyle,
          ),
          Input(
            controller: _description,
            maxLines: 6,
            hint: 'Tell us a little about yourself...',
          ),
          const SizedBox(height: 15),
          Button(
            onPressed: handleAccountCreation,
            label: 'Create Account',
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _authService.signOut();
          navigator.pushNamedAndRemoveUntil(landing, (_) => false);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
