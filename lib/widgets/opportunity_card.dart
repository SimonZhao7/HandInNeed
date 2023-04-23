import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity.dart';
// Constants
import 'package:hand_in_need/constants/route_args/id_args.dart';
import 'package:hand_in_need/constants/colors.dart';
import '../constants/route_names.dart';

class OpportunityCard extends StatefulWidget {
  final double cardWidth;
  final Opportunity opportunity;
  const OpportunityCard({
    super.key,
    required this.cardWidth,
    required this.opportunity,
  });

  @override
  State<OpportunityCard> createState() => _OpportunityCardState();
}

class _OpportunityCardState extends State<OpportunityCard> {
  bool enabled = false;

  void handleClick(e) {
    setState(() {
      enabled = !enabled;
    });
  }

  void handleUnclick() {
    setState(() {
      enabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final op = widget.opportunity;

    return SizedBox(
      width: widget.cardWidth,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            viewOpportunity,
            arguments: IdArgs(op.id),
          );
        },
        onTapDown: handleClick,
        onTapUp: handleClick,
        onTapCancel: handleUnclick,
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutExpo,
          decoration: BoxDecoration(
            color: enabled ? const Color(lightGray) : const Color(white),
            border: Border.all(
              width: 2,
              color: const Color(gray),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                op.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        op.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Text(
                        op.place.address,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
