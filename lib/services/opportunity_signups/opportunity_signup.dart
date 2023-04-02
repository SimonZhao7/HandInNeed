import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hand_in_need/services/opportunity_signups/fields.dart';

class OpportunitySignup {
  final String id;
  final String userId;
  final String opportunityId;
  final String? verifiedEmail;
  final String password;

  const OpportunitySignup({
    required this.id,
    required this.userId,
    required this.opportunityId,
    required this.verifiedEmail,
    required this.password,
  });

  factory OpportunitySignup.fromFirebase(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return OpportunitySignup(
      id: snapshot.id,
      userId: data[userIdField],
      opportunityId: data[opportunityIdField],
      verifiedEmail: data[verifiedEmailField],
      password: data[passwordField],
    );
  }
}
