import 'package:flutter/material.dart';
// Bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hand_in_need/bloc/maps/map_bloc.dart';
import 'package:hand_in_need/bloc/maps/map_events.dart';
import 'package:hand_in_need/bloc/maps/map_states.dart';
// Services
import 'package:hand_in_need/services/google_places/autocomplete_result.dart';
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import 'package:hand_in_need/services/geolocator/geolocator_exceptions.dart';
import '../services/opportunities/opportunity.dart';
// Widgets
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hand_in_need/views/address_search_view.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/input.dart';
import '../widgets/opportunity_card.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
// Extensions
import '../extensions/navigator.dart';
// Util
import 'dart:async';

class HomeContentView extends StatefulWidget {
  const HomeContentView({super.key});

  @override
  State<HomeContentView> createState() => _HomeContentViewState();
}

class _HomeContentViewState extends State<HomeContentView> {
  final _controller = Completer<GoogleMapController>();
  final opportunityService = OpportunityService();
  final scrollController = ScrollController();
  OverlayEntry? overlay;
  late TextEditingController _search;

  final double cardWidth = 250.0;

  @override
  void initState() {
    _search = TextEditingController();
    super.initState();
  }

  Set<Marker> getMarkers(List<Opportunity> opportunities) {
    return opportunities
        .map(
          (o) => Marker(
            onTap: () {
              final index = opportunities.indexOf(o);
              scrollController.animateTo(
                index * cardWidth,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutExpo,
              );
            },
            markerId: MarkerId(o.place.placeId),
            infoWindow: InfoWindow(
              title: o.title,
            ),
            position: o.place.location,
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => MapBloc()..add(const InitializeEvent()),
      child: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state.loading && overlay == null) {
            overlay = OverlayEntry(builder: (context) {
              return Container(
                color: Colors.black26,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Loading...',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .apply(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              );
            });
            Overlay.of(context)?.insert(overlay!);
          } else if (!state.loading) {
            overlay?.remove();
            overlay = null;
          }
          if (state is PositionSuccessState) {
            _controller.future.then(
              (c) => c.animateCamera(
                CameraUpdate.newLatLng(state.position),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: state is PositionFailState
                  ? const Text('Home')
                  : Input(
                      controller: _search,
                      fillColor: white,
                      readOnly: true,
                      hint: 'Search for a location...',
                      onTap: () async {
                        Navigator.of(context)
                            .pushSlideRoute<AutocompleteResult>(
                                const AddressSearchView())
                            .then(
                          (result) {
                            if (result != null) {
                              _search.text = result.description;
                              context
                                  .read<MapBloc>()
                                  .add(UpdateLocationEvent(result));
                            }
                          },
                        );
                      },
                    ),
            ),
            body: state is PositionFailState
                ? Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.exception
                                  is LocationPermissionDeniedForeverGeolocatorException
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
                  )
                : StreamBuilder(
                    stream: opportunityService.allOpportunities(state.bounds),
                    initialData: const <Opportunity>[],
                    builder: (context, snapshot) {
                      final opportunities = snapshot.data!;
                      return Stack(
                        children: [
                          GoogleMap(
                            onMapCreated:
                                (GoogleMapController controller) async {
                              _controller.complete(controller);
                            },
                            onCameraIdle: () {
                              _controller.future.then((c) => context
                                  .read<MapBloc>()
                                  .add(BoundsUpdateEvent(c)));
                            },
                            markers: getMarkers(opportunities),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: state.position,
                              zoom: 14,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 200,
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: opportunities.isEmpty
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          'No results found.',
                                          style: textStyle.headline3,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      controller: scrollController,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: opportunities.length,
                                      itemBuilder: (context, index) {
                                        final op = opportunities[index];
                                        return OpportunityCard(
                                          cardWidth: cardWidth,
                                          opportunity: op,
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(width: 20);
                                      },
                                    ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: GestureDetector(
                              onTap: () {
                                _controller.future.then((c) => context
                                    .read<MapBloc>()
                                    .add(BoundsUpdateEvent(c)));
                              },
                              child: const Chip(
                                label: Text(
                                  'Search This Area',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
