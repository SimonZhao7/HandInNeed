import 'package:cloud_firestore/cloud_firestore.dart';

extension DateFilter on Query<Map<String, dynamic>> {
  Query<Map<String, dynamic>> filterTime({
    required bool past,
    required String fieldName,
  }) {
    return past
        ? where(fieldName, isLessThanOrEqualTo: Timestamp.now())
        : where(fieldName, isGreaterThan: Timestamp.now());
  }
}