// where user if they do not have an account be able to register an acccount with email and password

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hand_in_need/firebase/firebase_auth_methods.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // function that registers our user want abstract from UI a bit will prob move later when we want refactor with bloc
  Future<void> signUpUser() async {
    FirebaseAuthMethods(FirebaseAuth.instance).signUpWithEmail(
      email: _email.text,
      password: _password.text,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Center(child: Text('Register')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: (Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\nEnter your email and password to get involved!\n',
                style: TextStyle(fontSize: 16),
              ),
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email here',
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your password here',
                ),
              ),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        signUpUser();
                      },
                      child: const Text('Sign up'),
                    ),
                    // Create a already registered login here button that takes to the login view
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              'login', (route) => false);
                        },
                        child: const Text('Already Registered? Login Here!')),
                  ],
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
