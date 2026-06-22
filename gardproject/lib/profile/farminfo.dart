import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gardproject/Api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kBg = Color(0xFFF3F4F6);
const Color kCardBg = Color(0xFFEFEFEF);
const Color kAccent = Color(0xFFB5DD47);
const Color kTextDark = Color(0xFF101010);
const Color kFieldFill = Color(0xFFF8F8F8);

class FarmApiService {
  static Future<Map<String, dynamic>> updateFarmInfo({
    required String farmSize,
    required String cropTypes,
    required String soilType,
    required String irrigationType,
    required DateTime plantingDate,
    required double lat,
    required double lng,
    String locationText = '',
    String name = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/farm');

    final body = {
      "name": name,
      "farmSize": farmSize,
      "cropTypes": cropTypes,
      "soilType": soilType,
      "irrigationType": irrigationType,
      "plantingDate": plantingDate.toIso8601String(),
      "locationText": locationText,
      "geo": {
        "lat": lat,
        "lng": lng,
      }
    };

  
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      throw Exception(decoded['message'] ?? 'Failed to update farm info');
    }
  }
}

class FarmInfoUpdateScreen extends StatefulWidget {
  final VoidCallback onBack;

  const FarmInfoUpdateScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<FarmInfoUpdateScreen> createState() =>
      _FarmInfoUpdateScreenState();
}

class _FarmInfoUpdateScreenState
    extends State<FarmInfoUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController farmSizeController =
      TextEditingController();

  final TextEditingController cropsController =
      TextEditingController();

  final TextEditingController soilTypeController =
      TextEditingController();

  final TextEditingController irrigationTypeController =
      TextEditingController();

  bool showCalendar = false;
  bool isLoading = false;

  DateTime? selectedDate;

  LatLng farmLocation = const LatLng(30.0444, 31.2357);

  @override
  void dispose() {
    farmSizeController.dispose();
    cropsController.dispose();
    soilTypeController.dispose();
    irrigationTypeController.dispose();
    super.dispose();
  }

  String get formattedDate {
    if (selectedDate == null) return "";

    final day =
        selectedDate!.day.toString().padLeft(2, '0');

    final month =
        selectedDate!.month.toString().padLeft(2, '0');

    final year = selectedDate!.year.toString();

    return "$day/$month/$year";
  }

  Future<void> onUpdatePressed() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select planting date"),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await FarmApiService.updateFarmInfo(
        farmSize: farmSizeController.text.trim(),
        cropTypes: cropsController.text.trim(),
        soilType: soilTypeController.text.trim(),
        irrigationType:
            irrigationTypeController.text.trim(),
        plantingDate: selectedDate!,
        lat: farmLocation.latitude,
        lng: farmLocation.longitude,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Farm info updated successfully",
          ),
        ),
      );

      widget.onBack();
    } catch (e) {
      print("UPDATE ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();

        if (showCalendar) {
          setState(() {
            showCalendar = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  10,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: widget.onBack,
                      borderRadius:
                          BorderRadius.circular(20),
                      child: const Padding(
                        padding:
                            EdgeInsets.all(6),
                        child: Icon(
                          Icons.arrow_back_outlined,
                          size: 24,
                          color: kTextDark,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Farm info update",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w500,
                            color: kTextDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      22,
                    ),
                    decoration: BoxDecoration(
                     color:  Colors.white.withOpacity(0.6),
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const _SectionLabel(
                              "Location/Address"),

                          const SizedBox(
                              height: 10),

                          _FarmMapPicker(
                            location:
                                farmLocation,
                            onLocationChanged:
                                (newLocation) {
                              setState(() {
                                farmLocation =
                                    newLocation;
                              });
                            },
                          ),

                          const SizedBox(
                              height: 8),

                          const _SectionLabel(
                              "Farm Size"),

                          const SizedBox(
                              height: 5),

                          _CustomInputField(
                            controller:
                                farmSizeController,
                            validator:
                                (value) {
                              if ((value ?? '')
                                  .trim()
                                  .isEmpty) {
                                return "Please enter farm size";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(
                              height: 11),

                          const _SectionLabel(
                              "Type of Crops / Plants"),

                          const SizedBox(
                              height: 5),

                          _CustomInputField(
                            controller:
                                cropsController,
                            validator:
                                (value) {
                              if ((value ?? '')
                                  .trim()
                                  .isEmpty) {
                                return "Please enter crop type";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(
                              height: 11),

                          const _SectionLabel(
                              "Soil Type"),

                          const SizedBox(
                              height: 5),

                          _CustomInputField(
                            controller:
                                soilTypeController,
                            validator:
                                (value) {
                              if ((value ?? '')
                                  .trim()
                                  .isEmpty) {
                                return "Please enter soil type";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(
                              height: 11),

                          const _SectionLabel(
                              "Planting Date"),

                          const SizedBox(
                              height: 5),

                          InkWell(
                            onTap: () {
                              FocusScope.of(
                                      context)
                                  .unfocus();

                              setState(() {
                                showCalendar =
                                    !showCalendar;
                              });
                            },
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                            child: Container(
                              height: 54,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 14,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            12),
                                border:
                                    Border.all(
                                  color:
                                      const Color(
                                    0xFFEAEAEA,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .calendar_today,
                                    size: 18,
                                    color: Color(
                                      0xFF9B9B9B,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 12),
                                  Expanded(
                                    child: Text(
                                      formattedDate,
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            15,
                                        color:
                                            kTextDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (showCalendar)
                            ...[
                              const SizedBox(
                                  height: 14),

                              Container(
                                width: double
                                    .infinity,
                                padding:
                                    const EdgeInsets
                                        .all(8),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFF6F6F6,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              14),
                                ),
                                child:
                                    CalendarDatePicker(
                                  initialDate:
                                      selectedDate ??
                                          DateTime
                                              .now(),
                                  firstDate:
                                      DateTime(
                                          2020),
                                  lastDate:
                                      DateTime(
                                          2035),
                                  onDateChanged:
                                      (date) {
                                    setState(() {
                                      selectedDate =
                                          date;
                                      showCalendar =
                                          false;
                                    });
                                  },
                                ),
                              ),
                            ],

                          const SizedBox(
                              height: 11),

                          const _SectionLabel(
                              "Irrigation Type"),

                          const SizedBox(
                              height: 5),

                          _CustomInputField(
                            controller:
                                irrigationTypeController,
                            validator:
                                (value) {
                              if ((value ?? '')
                                  .trim()
                                  .isEmpty) {
                                return "Please enter irrigation type";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(
                              height: 11),

                        SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    onPressed: isLoading ? null : onUpdatePressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: kTextDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ), side: const BorderSide(
      color: Colors.black,
      width: 1.5,
    ),
    ),
    child: isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          )
        : const Text(
            "Update",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmMapPicker extends StatelessWidget {
  final LatLng location;
  final ValueChanged<LatLng>
      onLocationChanged;

  const _FarmMapPicker({
    required this.location,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(12),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: location,
            initialZoom: 13,
            minZoom: 5,
            maxZoom: 18,
            onTap:
                (tapPosition, point) {
              onLocationChanged(point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName:
                  'gardproject',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: location,
                  width: 23,
                  height: 23,
                  child: Container(
                    decoration:
                        BoxDecoration(
                      color: kAccent,
                      shape:
                          BoxShape.circle,
                      border: Border.all(
                        color:
                            Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: kTextDark,
      ),
    );
  }
}

class _CustomInputField extends StatelessWidget {
  final TextEditingController
      controller;

  final String? Function(String?)?
      validator;

  const _CustomInputField({
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(
        fontSize: 10,
        color: kTextDark,
      ),
    decoration: InputDecoration(
  filled: true,
  fillColor: Colors.white,

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Color(0xFFE5E5E5),
      width: 1,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Color(0xFFE5E5E5),
      width: 1,
    ),
  ),

  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Color(0xFFE5E5E5),
      width: 1,
    ),
  ),
),
    );
  }
}