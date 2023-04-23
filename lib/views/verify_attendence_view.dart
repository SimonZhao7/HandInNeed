import 'package:flutter/material.dart';

class VerifyAttendenceView extends StatelessWidget {
  const VerifyAttendenceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text('Verify')
        ),
      ),
    );
  }
}
