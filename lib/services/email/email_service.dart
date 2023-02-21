import 'package:hand_in_need/services/email/templates/verify_opportunity_email.dart';
// Util
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static final EmailService _shared = EmailService._sharedInstance();
  EmailService._sharedInstance();
  factory EmailService() => _shared;

  Future<void> sendOpportunityVerificationEmail({
    required String toEmail,
    required Uri dynamicLink,
  }) async {
    await sendEmail(
      toEmail: toEmail,
      fromEmail: 'handinneedgsdc@gmail.com',
      fromName: 'The HandInNeed Team',
      subject: 'Volunteer Opportunity Hosting',
      template: verifyOpportunityEmail(dynamicLink),
    );
  }

  Future<void> sendEmail({
    required String toEmail,
    required String fromEmail,
    required String fromName,
    required String subject,
    required String template,
  }) async {
    final sendEmailUrl = Uri.https(
      'api.sendgrid.com',
      '/v3/mail/send',
    );

    await http.post(
      sendEmailUrl,
      headers: {
        'Authorization': 'Bearer ${dotenv.env['SENDGRID_API_KEY']}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'personalizations': [
          {
            'to': [
              {
                'email': toEmail,
              }
            ],
          }
        ],
        'from': {
          'email': fromEmail,
          'name': fromName,
        },
        'subject': subject,
        'content': [
          {
            'type': 'text/html',
            'value': template,
          }
        ],
      }),
    );
  }
}
