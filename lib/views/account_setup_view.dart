import 'dart:io';
import 'package:flutter/material.dart';
// Widgets
import '../widgets/button.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';
// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Constants
import '../constants/routes.dart';
// Util
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class AccountSetupView extends StatefulWidget {
  const AccountSetupView({super.key});

  @override
  State<AccountSetupView> createState() => _AccountSetupViewState();
}

class _AccountSetupViewState extends State<AccountSetupView> {
  late TextEditingController _email;
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _userName;
  late TextEditingController _description;
  XFile? image;

  @override
  void initState() {
    _email = TextEditingController();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _userName = TextEditingController();
    _description = TextEditingController();
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
    final user = FirebaseAuth.instance.currentUser!;
    final focus = FocusScope.of(context);
    final navigator = Navigator.of(context);
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: userName)
        .get();

    if (!focus.hasPrimaryFocus) {
      focus.unfocus();
    }

    try {
      if (email.trim().isEmpty) {
        showErrorSnackbar(context, 'No email provided');
        return;
      }

      if (userName.trim().isEmpty) {
        showErrorSnackbar(context, 'No username provided');
        return;
      }

      if (userName.trim().length < 8) {
        showErrorSnackbar(
          context,
          'Username must be at least 8 characters long',
        );
        return;
      }

      if (users.docs.isNotEmpty) {
        showErrorSnackbar(
          context,
          'A user already exists with the provided username',
        );
        return;
      }

      if (firstName.trim().isEmpty) {
        showErrorSnackbar(context, 'No first name provided');
        return;
      }

      if (lastName.trim().isEmpty) {
        showErrorSnackbar(context, 'No last name provided');
        return;
      }

      if (image == null) {
        showErrorSnackbar(context, 'No profile picture provided');
        return;
      }

      await user.updateEmail(email);

      final ref = FirebaseStorage.instance.ref(
        'profile_images/${const Uuid().v4()}-${image!.name}',
      );
      final uploadState = ref.putFile(File(image!.path));
      uploadState.snapshotEvents.listen((TaskSnapshot event) async {
        switch (event.state) {
          case TaskState.paused:
            break;
          case TaskState.running:
            break;
          case TaskState.canceled:
            break;
          case TaskState.error:
            break;
          case TaskState.success:
            final url = await ref.getDownloadURL();
            await user.updatePhotoURL(url);
        }
      });

      await FirebaseFirestore.instance.collection('users').add({
        'user_id': user.uid,
        'username': userName,
        'first_name': firstName,
        'last_name': lastName,
        'description': description,
        'hours_worked': 0,
        'opportunities': [],
      });
      await user.sendEmailVerification();
      navigator.pushNamedAndRemoveUntil(homeRoute, (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        showErrorSnackbar(context, 'The email provided is invalid');
      } else if (e.code == 'email-already-in-use') {
        showErrorSnackbar(
          context,
          'A user already exists with the provided email',
        );
      } else {
        showErrorSnackbar(context, 'Something went wrong');
      }
    } catch (e) {
      showErrorSnackbar(context, 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(30, 120, 30, 30),
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
    );
  }
}
