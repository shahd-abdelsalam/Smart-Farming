import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gardproject/profile/navigation.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OsmFullMapPage extends StatefulWidget {
  const OsmFullMapPage({super.key});

  @override
  State<OsmFullMapPage> createState() => _OsmFullMapPageState();
}

class _OsmFullMapPageState extends State<OsmFullMapPage> {
  final MapController _map = MapController();

  static const LatLng mansoura = LatLng(31.0409, 31.3785);

  LatLng? _me;
  LatLng _center = mansoura;

  bool _gettingLocation = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToMe();
    });
  }

  Future<void> _moveToMe() async {
    setState(() => _gettingLocation = true);

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final me = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _me = me;
        _center = me;
        _gettingLocation = false;
      });

      _map.move(me, 16);
    } catch (_) {
      setState(() => _gettingLocation = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Can't find location")),
      );
    }
  }

  Future<void> _savePicked() async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('farm_name', 'My Farm');
      await prefs.setDouble('farm_lat', _center.latitude);
      await prefs.setDouble('farm_lng', _center.longitude);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Navigation(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Local Save Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: mansoura,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onPositionChanged: (position, hasGesture) {
                final currentCenter = position.center;
                if (hasGesture && currentCenter != null) {
                  _center = currentCenter;
                  setState(() {});
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.gardproject",
              ),
              MarkerLayer(
                markers: [
                  if (_me != null)
                    Marker(
                      point: _me!,
                      width: 46,
                      height: 46,
                      child: const Icon(Icons.my_location, size: 30),
                    ),
                ],
              ),
            ],
          ),

          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: const Icon(
                  Icons.location_on,
                  size: 46,
                  color: Colors.red,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _pillButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _pillButton(
                    icon: Icons.my_location,
                    onTap: _moveToMe,
                  ),
                ],
              ),
            ),
          ),

          if (_gettingLocation)
            const Center(
              child: CircularProgressIndicator(),
            ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    color: Color(0x22000000),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Lat: ${_center.latitude.toStringAsFixed(6)}\n"
                    "Lng: ${_center.longitude.toStringAsFixed(6)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _savePicked,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Save Location"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(0, 6),
              color: Color(0x22000000),
            )
          ],
        ),
        child: Icon(icon),
      ),
    );
  }
}