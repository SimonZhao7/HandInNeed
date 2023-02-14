import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
import '../services/opportunities/opportunity.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/link_text.dart';
// Util
import 'package:transparent_image/transparent_image.dart';
import 'package:intl/intl.dart';

class OpportunityDetailsView extends StatelessWidget {
  final Opportunity opportunity;
  const OpportunityDetailsView({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final place = opportunity.place;
    final textStyle = Theme.of(context).textTheme;
    final dateFormat = DateFormat.yMd().add_jm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
      ),
      body: DefaultTextStyle(
        style: textStyle.labelMedium!,
        child: ListView(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 250,
                minWidth: double.infinity,
              ),
              child: Stack(
                children: [
                  const Center(child: CircularProgressIndicator()),
                  FadeInImage.memoryNetwork(
                    fadeInDuration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    image: opportunity.image,
                    fit: BoxFit.cover,
                    placeholder: kTransparentImage,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opportunity.title, style: textStyle.headline2),
                  const SizedBox(height: 25),
                  Text(opportunity.description),
                  const SizedBox(height: 40),
                  Text('Important Dates', style: textStyle.headline3),
                  const SizedBox(height: 15),
                  Text(
                    'Starts on: ${dateFormat.format(opportunity.startTime)}',
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Ends on: ${dateFormat.format(opportunity.endTime)}',
                  ),
                  const SizedBox(height: 40),
                  Text(place.name, style: textStyle.headline3),
                  const SizedBox(height: 15),
                  Text('Address: ${place.address}'),
                  const SizedBox(height: 15),
                  LinkText(
                    leading: 'Organization Website: ',
                    url: opportunity.url,
                    scheme: 'https',
                  ),
                  const SizedBox(height: 15),
                  LinkText(
                    leading: 'Place Website: ',
                    url: place.website,
                    scheme: 'https',
                  ),
                  const SizedBox(height: 60),
                  Text('Contact Info', style: textStyle.headline3),
                  const SizedBox(height: 15),
                  LinkText(
                    leading: 'Phone Number: ',
                    url: place.phoneNumber,
                    scheme: 'tel',
                  ),
                  const SizedBox(height: 15),
                  LinkText(
                    leading: 'Email: ',
                    url: opportunity.organizationEmail,
                    scheme: 'mailto',
                  ),
                  const SizedBox(height: 40),
                  Button(
                    onPressed: () {},
                    label: opportunity.attendees
                            .contains(authService.userDetails.uid)
                        ? 'Joined'
                        : 'Join',
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
