import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/google_places/google_places_exceptions.dart';
import 'package:hand_in_need/services/opportunities/opportunity_exceptions.dart';
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import 'package:hand_in_need/views/address_search_view.dart';
// Widgets
import 'package:hand_in_need/widgets/dialogs/delete_confirmation.dart';
import '../services/google_places/autocomplete_result.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';
import 'package:image_picker/image_picker.dart';
import '../services/opportunities/opportunity.dart';
import '../widgets/button.dart';
// Constants
import 'package:hand_in_need/constants/route_names.dart';
import 'package:hand_in_need/constants/colors.dart';
// Util
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AddOpportunity extends StatefulWidget {
  final Opportunity? opportunity;
  const AddOpportunity({super.key, this.opportunity});

  @override
  State<AddOpportunity> createState() => _AddOpportunityState();
}

class _AddOpportunityState extends State<AddOpportunity> {
  final OpportunityService _opportunityService = OpportunityService();
  late TextEditingController _title;
  late TextEditingController _description;
  late TextEditingController _url;
  late TextEditingController _organizationEmail;
  late TextEditingController _address;
  XFile? selectedPhoto;
  DateTime? startDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  AutocompleteResult? location;

  @override
  void initState() {
    _title = TextEditingController();
    _description = TextEditingController();
    _url = TextEditingController();
    _organizationEmail = TextEditingController();
    _address = TextEditingController();

    final opportunity = widget.opportunity;
    if (opportunity != null) {
      final place = opportunity.place;
      final autoLocation = AutocompleteResult(
        description: '${place.name}, ${place.address}',
        placeId: place.placeId,
      );

      _title.text = opportunity.title;
      _description.text = opportunity.description;
      _url.text = opportunity.url;
      _organizationEmail.text = opportunity.organizationEmail;
      startDate = opportunity.startDate;
      startTime = TimeOfDay.fromDateTime(opportunity.startTime);
      endTime = TimeOfDay.fromDateTime(opportunity.endTime);
      location = autoLocation;
      _address.text = autoLocation.description;
    }
    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _url.dispose();
    _organizationEmail.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd();
    final label = Theme.of(context).textTheme.labelMedium;
    final editing = widget.opportunity != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${editing ? 'Edit' : 'Add'} Opportunity'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title',
                style: label,
              ),
              Input(
                controller: _title,
                autofocus: true,
              ),
              Text('Description', style: label),
              Input(
                controller: _description,
                maxLines: 5,
              ),
              Text('Website', style: label),
              Input(controller: _url),
              Text('Organization Email', style: label),
              Input(controller: _organizationEmail),
              const SizedBox(height: 10),
              if (selectedPhoto != null) ...[
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Image.file(
                    File(selectedPhoto!.path),
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (editing && selectedPhoto == null) ...[
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Image.network(
                    widget.opportunity!.image,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              Text('Image', style: label),
              Button(
                onPressed: () async {
                  final imagePicker = ImagePicker();
                  final XFile? photo = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (photo == null) return;
                  // Convert to and store bytes
                  setState(() {
                    selectedPhoto = photo;
                  });
                },
                label: 'Choose a photo',
              ),
              const SizedBox(height: 10),
              Text(
                'Start Date',
                style: label,
              ),
              Button(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      const Duration(
                        days: 365,
                      ),
                    ),
                    initialEntryMode: DatePickerEntryMode.input,
                  );
                  setState(() {
                    startDate = selectedDate ?? startDate;
                  });
                },
                label: startDate != null
                    ? dateFormat.format(startDate!)
                    : 'Select a start date',
              ),
              const SizedBox(height: 10),
              Text('Start Time', style: label),
              Button(
                onPressed: () async {
                  final selectedTime = await _showTimeInput(time: startTime);
                  setState(() {
                    startTime = selectedTime ?? startTime;
                  });
                },
                label: startTime != null
                    ? startTime!.format(context)
                    : 'Select a start time',
              ),
              const SizedBox(height: 10),
              Text('End Time', style: label),
              Button(
                onPressed: () async {
                  final selectedTime = await _showTimeInput(time: endTime);
                  setState(() {
                    endTime = selectedTime ?? endTime;
                  });
                },
                label: endTime != null
                    ? endTime!.format(context)
                    : 'Select an end time',
              ),
              const SizedBox(height: 10),
              Text('Address', style: label),
              Input(
                readOnly: true,
                controller: _address,
                onTap: () async {
                  final address = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddressSearchView(),
                    ),
                  ) as AutocompleteResult?;
                  if (address == null) return;
                  _address.text = address.description;
                  setState(() {
                    location = address;
                  });
                },
              ),
              const SizedBox(height: 10),
              Button(
                  onPressed: _handleSubmit,
                  label: editing ? 'Update' : 'Submit'),
              if (editing) ...[
                const SizedBox(height: 10),
                Button(
                  onPressed: _showDeleteDialog,
                  label: 'Delete',
                  backgroundColor: negativeRed,
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    final editing = widget.opportunity != null;
    final title = _title.text;
    final description = _description.text;
    final url = _url.text;
    final organizationEmail = _organizationEmail.text;
    final navigator = Navigator.of(context);

    try {
      if (editing) {
        await _opportunityService.updateOpportunity(
          id: widget.opportunity!.id,
          title: title,
          description: description,
          url: url,
          organizationEmail: organizationEmail,
          selectedPhoto: selectedPhoto,
          startDate: startDate,
          startTime: startTime,
          endTime: endTime,
          location: location,
        );
      } else {
        await _opportunityService.addOpportunity(
          title: title,
          description: description,
          url: url,
          organizationEmail: organizationEmail,
          selectedPhoto: selectedPhoto,
          startDate: startDate,
          startTime: startTime,
          endTime: endTime,
          location: location,
        );
      }
      navigator.pop();
    } catch (e) {
      if (e is TitleTooShortOpportunityException) {
        showErrorSnackbar(context, 'Provided title is too short');
      } else if (e is NoUrlProvidedOpportunityException) {
        showErrorSnackbar(context, 'No url provided');
      } else if (e is InvalidUrlOpportunityException) {
        showErrorSnackbar(
          context,
          'Please enter a valid url',
        );
      } else if (e is NoOrganizationEmailProvidedOpportunityException) {
        showErrorSnackbar(context, 'No organization email provided');
      } else if (e is InvalidOrganizationEmailOpportunityException) {
        showErrorSnackbar(context, 'Invalid email');
      } else if (e is NoPhotoProvidedOpportunityException) {
        showErrorSnackbar(context, 'No photo provided');
      } else if (e is NoStartDateProvidedOpportunityException) {
        showErrorSnackbar(context, 'No start date provided');
      } else if (e is NoStartTimeProvidedOpportunityException) {
        showErrorSnackbar(context, 'No start time provided');
      } else if (e is NoEndTimeProvidedOpportunityExcpeption) {
        showErrorSnackbar(context, 'No end time provided');
      } else if (e is InvalidStartTimeOpportunityException) {
        showErrorSnackbar(context, 'Invalid start time');
      } else if (e is OutOfOrderTimesOpportunityException) {
        showErrorSnackbar(
          context,
          'The end time must be later than the start time',
        );
      } else if (e is NoLocationProvidedOpportunityExcpetion) {
        showErrorSnackbar(context, 'No location provided');
        return;
      } else if (e is UnableToFetchGooglePlacesException) {
        showErrorSnackbar(
          context,
          'Unable to fetch location details. Please enter a different location.',
        );
      } else {
        showErrorSnackbar(context, 'Something went wrong');
      }
    }
  }

  void _showDeleteDialog() async {
    final value = await showDeleteConfirmationDialog(
          context,
          'Are you sure you want to delete this opportunity?',
        ) ??
        false;
    if (value) {
      _opportunityService
          .deleteOpportunity(widget.opportunity!.id)
          .then((_) => context.goNamed(home));
    }
  }

  Future<TimeOfDay?> _showTimeInput({TimeOfDay? time}) {
    return showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
  }
}
