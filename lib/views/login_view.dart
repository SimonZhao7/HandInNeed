import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hand_in_need/firebase/firebase_auth_methods.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  // GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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

  // function that loggs in the user
  Future<void> loginUser() async {
    FirebaseAuthMethods(FirebaseAuth.instance).loginWithEmail(
      email: _email.text,
      password: _password.text,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Center(
          child: Text('Login'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: (Column(
          children: [
            const Text(
              '\nPlease Login to your account so we can begin looking for opportunities near you!\n',
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
            TextButton(
              onPressed: () async {
                loginUser();
              },
              child: const Text('\nLogin'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('register', (context) => false);
                },
                child: const Text('\nNot Registered yet? Register Here!')),
            // add a button so that if user forgot password give them option to
            TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?'),
            ),
            // Login with Google
            TextButton(
              onPressed: () {},
              child: const Text('Login with Google'),
            ),
            // Login with Facebook
            TextButton(
              onPressed: () {},
              child: const Text('Login with Facebook'),
            ),
          ],
        )),
      ),
    );
  }
}
