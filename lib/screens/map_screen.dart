import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/space_provider.dart';
import '../models/coworking_space_model.dart';
import 'space_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _hasLocationPermission = false;
  LatLng? _userLatLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers();
    });
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Optionally prompt user to enable location services
        setState(() {
          _hasLocationPermission = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _hasLocationPermission = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _hasLocationPermission = true;
        _userLatLng = latLng;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 14),
          ),
        );
      }
    } catch (e) {
      // Keep default camera if any error
      setState(() {
        _hasLocationPermission = false;
      });
    }
  }

  void _updateMarkers() {
    final spaceProvider = context.read<SpaceProvider>();
    _markers = spaceProvider.spaces.map((space) {
      return Marker(
        markerId: MarkerId(space.id),
        position: LatLng(space.latitude, space.longitude),
        infoWindow: InfoWindow(
          title: space.name,
          snippet: '₹${space.pricePerHour}/hour',
          onTap: () => _navigateToSpaceDetail(space),
        ),
        onTap: () => _showSpaceBottomSheet(space),
      );
    }).toSet();

    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToSpaceDetail(CoworkingSpaceModel space) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpaceDetailScreen(space: space)),
    );
  }

  void _showSpaceBottomSheet(CoworkingSpaceModel space) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              space.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(space.location, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                Text(' ${space.rating}'),
                const Spacer(),
                Text(
                  '₹${space.pricePerHour}/hour',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToSpaceDetail(space);
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpaceProvider>(
      builder: (context, spaceProvider, child) {
        if (spaceProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (spaceProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Error: ${spaceProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => spaceProvider.loadSpaces(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Update markers when spaces change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateMarkers();
        });

        final initial = _userLatLng ?? const LatLng(19.0760, 72.8777); // Mumbai

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initial,
            zoom: _userLatLng != null ? 14 : 10,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            if (_userLatLng != null) {
              _mapController!.moveCamera(
                CameraUpdate.newLatLngZoom(_userLatLng!, 14),
              );
            }
          },
          myLocationEnabled: _hasLocationPermission,
          myLocationButtonEnabled: true,
        );
      },
    );
  }
}
