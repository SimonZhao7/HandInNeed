import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hand_in_need/services/opportunities/fields.dart';
import 'package:hand_in_need/services/opportunities/place.dart';

class Opportunity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String url;
  final String image;
  final String organizationEmail;
  final bool verified;
  final DateTime startDate;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final List<String> attendees;
  final Place place;

  Opportunity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.url,
    required this.image,
    required this.organizationEmail,
    required this.verified,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.attendees,
    required this.place,
  });

  factory Opportunity.fromFirebase(QueryDocumentSnapshot snapshot) {
    final id = snapshot.id;
    final data = snapshot.data() as Map<String, dynamic>;
    return Opportunity(
      id: id,
      userId: data[userIdField],
      title: data[titleField],
      description: data[descriptionField],
      url: data[urlField],
      image: data[imageField],
      organizationEmail: data[organizationEmailField],
      verified: data[verifiedField],
      startDate: (data[startDateField] as Timestamp).toDate(),
      startTime: (data[startTimeField] as Timestamp).toDate(),
      endTime: (data[endTimeField] as Timestamp).toDate(),
      createdAt: (data[createdAtField] as Timestamp).toDate(),
      attendees: data[attendeesField] as List<String>,
      place: Place.fromJson(data[placeField]),
    );
  }
}
