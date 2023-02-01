// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Constants
import 'auth_constants.dart';

class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String userName;
  final String description;
  final String displayImage;
  final double hoursWorked;
  final List<String> opportunities;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.description,
    required this.displayImage,
    required this.hoursWorked,
    required this.opportunities,
  });

  factory AuthUser.fromFirebase(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final id = snapshot.id;
    final data = snapshot.data();
    final user = FirebaseAuth.instance.currentUser!;
    final List<dynamic> opportunities = data[opportunitiesField];

    return AuthUser(
      id: id,
      email: user.email!,
      firstName: data[firstNameField],
      lastName: data[lastNameField],
      userName: data[userNamefield],
      description: data[descriptionField],
      displayImage: user.photoURL!,
      hoursWorked: data[hoursWorkedField] == 0 ? 0.0 : data[hoursWorkedField],
      opportunities: opportunities.map((o) => o.toString()).toList(),
    );
  }
}
