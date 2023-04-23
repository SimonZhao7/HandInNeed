import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hand_in_need/services/notifications/fields.dart';


class DeviceTokens {
  final String id;
  final String userId;
  final List<String> tokens;

  const DeviceTokens({
    required this.id,
    required this.userId,
    required this.tokens,
  });

  factory DeviceTokens.fromFirebase(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final id = snapshot.id;
    final data = snapshot.data();
    return DeviceTokens(
      id: id,
      userId: data[userIdField],
      tokens: (data[tokensField] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }
}
