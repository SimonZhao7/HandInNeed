import 'package:flutter/material.dart';
// Firebase
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// Constants
import 'package:hand_in_need/constants/route_args/change_op_email_args.dart';
import 'package:hand_in_need/constants/route_names.dart';

class DeepLinksService {
  static final DeepLinksService _shared = DeepLinksService._sharedInstance();
  DeepLinksService._sharedInstance();
  factory DeepLinksService() => _shared;

  Future<Uri> createOpportunityVerifyDeepLink({
    required String id,
    required String hash,
  }) async {
    return await createDeepLink(
      id: id,
      hash: hash,
      domain: 'handinneed.page.link',
      path: '/opportunities/change-email/$id/$hash',
    );
  }

  Future<Uri> createDeepLink({
    required String id,
    required String hash,
    required String domain,
    required String path,
  }) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(
        'https://$domain$path',
      ),
      uriPrefix: 'https://$domain',
      androidParameters: const AndroidParameters(
        packageName: "com.example.hand_in_need",
      ),
    );
    return await FirebaseDynamicLinksPlatform.instance.buildLink(
      dynamicLinkParams,
    );
  }

  void handleLinkClicks(BuildContext context) {
    FirebaseDynamicLinks.instance.onLink.listen(
      (dynamicLinkData) {
        final pathValues = dynamicLinkData.link.path.split('/');
        Navigator.of(context).pushNamed(
          changeOpportunityEmail,
          arguments: ChangeOpportunityEmailArgs(
            opportunityId: pathValues[3],
            emailHash: pathValues[4],
          ),
        );
      },
    ).onError((_) {});
  }
}
