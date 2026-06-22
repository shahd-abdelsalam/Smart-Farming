import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import 'osm_full_map_page.dart';

class LocationPermissionOsmScreen extends StatefulWidget {
  const LocationPermissionOsmScreen({super.key});

  @override
  State<LocationPermissionOsmScreen> createState() =>
      _LocationPermissionOsmScreenState();
}

class _LocationPermissionOsmScreenState
    extends State<LocationPermissionOsmScreen> {
  bool _loading = false;

  static const LatLng mansoura= LatLng(30.0444, 31.2357);

  Future<void> _allow() async {
    setState(() => _loading = true);

    final gpsOn = await Geolocator.isLocationServiceEnabled();
    if (!gpsOn) {
      setState(() => _loading = false);
      await Geolocator.openLocationSettings();
      return;
    }

    final status = await Permission.locationWhenInUse.request();
    setState(() => _loading = false);

    if (status.isGranted) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OsmFullMapPage()),
      );
      return;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("لازم تسمحي باللوكيشن عشان نكمّل.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEFEFF4);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 18,
                      offset: Offset(0, 10),
                      color: Color(0x18000000),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 18),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'Allow "App" to use\nyour location?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          "Your precise location is used to show\nyour position on the map, get\ndirections, estimate travel times and\nimprove search results.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: FlutterMap(
                          options: const MapOptions(
                            initialCenter: mansoura,
                            initialZoom: 15,
                            interactionOptions: InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              userAgentPackageName: "com.example.gardproject",
                            ),
                            const MarkerLayer(
                              markers: [
                                Marker(
                                  point: mansoura,
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.location_on, size: 34),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      _iosButton(
                        text: "Allow Once",
                        onTap: _loading ? null : _allow,
                        loading: _loading,
                      ),
                      const Divider(height: 1),
                      _iosButton(
                        text: "Allow While Using the App",
                        onTap: _loading ? null : _allow,
                      ),
                      const Divider(height: 1),
                      _iosButton(
                        text: "Don't Allow",
                        onTap: _loading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        isDestructive: true,
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iosButton({
    required String text,
    required VoidCallback? onTap,
    bool isDestructive = false,
    bool loading = false,
  }) {
    final color = isDestructive
        ? const Color(0xFF111827)
        : const Color(0xFF111827);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: Center(
          child: loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
        ),
      ),
    );
  }
}