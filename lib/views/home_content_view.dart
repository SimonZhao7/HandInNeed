import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import 'package:hand_in_need/services/geolocator/geolocator_exceptions.dart';
import 'package:hand_in_need/services/geolocator/geolocator_service.dart';
import '../services/opportunities/opportunity.dart';
// Widgets
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hand_in_need/widgets/button.dart';
// Constants
import '../constants/route_names.dart';
// Util
import 'package:go_router/go_router.dart';

class HomeContentView extends StatefulWidget {
  const HomeContentView({super.key});

  @override
  State<HomeContentView> createState() => _HomeContentViewState();
}

class _HomeContentViewState extends State<HomeContentView> {
  GoogleMapController? _controller;
  final _geolocationService = GeoLocatorService();
  final _opportunityService = OpportunityService();

  @override
  Widget build(BuildContext context) {
    void setMapController(GoogleMapController controller) {
      _controller = controller;
    }

    Set<Marker> getMarkers(List<Opportunity> opportunities) {
      return opportunities
          .map(
            (o) => Marker(
              markerId: MarkerId(o.place.placeId),
              infoWindow: InfoWindow(
                title: o.title,
                onTap: () {
                  context.pushNamed(viewOpportunity, params: {'id': o.id});
                },
              ),
              position: o.place.location,
            ),
          )
          .toSet();
    }

    return FutureBuilder(
      future: _geolocationService.getCurrentLocation(),
      initialData: const LatLng(0, 0),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final deniedForever = snapshot.error
              is LocationPermissionDeniedForeverGeolocatorException;
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  deniedForever
                      ? 'Please enable location permissions in the settings'
                      : 'Location has been denied',
                  style: Theme.of(context).textTheme.headline3,
                ),
                const SizedBox(height: 20),
                Button(
                  onPressed: () {
                    setState(() {});
                  },
                  label: 'Enable Location',
                )
              ],
            ),
          );
        } else {
          final position = snapshot.data!;
          if (snapshot.connectionState == ConnectionState.done &&
              _controller != null) {
            _controller!.moveCamera(
              CameraUpdate.newLatLng(position),
            );
          }
          return StreamBuilder(
            stream: _opportunityService.allOpportunities(),
            initialData: const <Opportunity>[],
            builder: (context, snapshot) {
              final opportunities = snapshot.data!;
              return GoogleMap(
                onMapCreated: setMapController,
                markers: getMarkers(opportunities),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 15,
                ),
              );
            },
          );
        }
      },
    );
  }
}
