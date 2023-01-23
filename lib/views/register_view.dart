import 'package:flutter/material.dart';
// Widgets
import 'package:hand_in_need/widgets/input.dart';
import 'package:hand_in_need/widgets/button.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late TextEditingController _phoneNumber;

  @override
  void initState() {
    _phoneNumber = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Let's Begin!",
              style: Theme.of(context).textTheme.headline1,
            ),
            const SizedBox(height: 50),
            Text(
              'Please enter your phone number',
              style: Theme.of(context).textTheme.headline3,
            ),
            const SizedBox(height: 40),
            Input(
              controller: _phoneNumber,
              hint: 'E.g. 444-444-4444',
              type: TextInputType.phone,
              borderWidth: 2,
            ),
            const SizedBox(height: 40),
            Button(
              onPressed: () {},
              center: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_outlined),
                ],
              ),
              height: 55,
            ),
          ],
        ),
      ),
    );
  }
}
