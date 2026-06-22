import 'package:flutter/material.dart';
import 'package:gardproject/Api/api_client.dart';
import 'package:gardproject/Auth/confirm.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class Farminfo extends StatefulWidget {
  final String email;
  final String? debugVerifyToken;

  const Farminfo({
    super.key,
    required this.email,
    this.debugVerifyToken,
  });

  @override
  State<Farminfo> createState() => _FarminfoState();
}

class _FarminfoState extends State<Farminfo> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _farmSizeController = TextEditingController();
  final TextEditingController _cropTypesController = TextEditingController();
  final TextEditingController _soilTypeController = TextEditingController();
  final TextEditingController _irrigationTypeController =
      TextEditingController();

  bool _isLoading = false;
  bool _showCalendar = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _farmSizeController.dispose();
    _cropTypesController.dispose();
    _soilTypeController.dispose();
    _irrigationTypeController.dispose();
    super.dispose();
  }

  String get _formattedDate {
    if (_selectedDate == null) return "";
    final day = _selectedDate!.day.toString().padLeft(2, '0');
    final month = _selectedDate!.month.toString().padLeft(2, '0');
    final year = _selectedDate!.year.toString();
    return "$day/$month/$year";
  }

  InputDecoration _dec() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB5DD47), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Color(0xFF101828),
      ),
    );
  }

  Future<void> _submitFarmInfo() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select planting date"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiClient.post(
        "/api/farm-info",
        body: {
          'email': widget.email,
          'farmSize': _farmSizeController.text.trim(),
          'cropTypes': _cropTypesController.text.trim(),
          'soilType': _soilTypeController.text.trim(),
          'irrigationType': _irrigationTypeController.text.trim(),
          'plantingDate': _selectedDate!.toIso8601String(),
          'locationText': "Egypt, Mansoura",
          'geo': {
            'lat': 31.0409,
            'lng': 31.3785,
          },
        },
      );

      if (!mounted) return;

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]?.toString() ?? "Farm info saved"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Confirmation(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]?.toString() ?? "Farm info failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saving farm info failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return "Required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_showCalendar) {
          setState(() => _showCalendar = false);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "images/design.png",
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
  child: Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
        bottom: MediaQuery.of(context).viewInsets.bottom + 25,
      ),
      child: Container(
        width: 380.w,
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 34),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(0,0,3,2),
                            child: Icon(
                              Icons.arrow_back_outlined,
                              size: 26,
                              color: Color(0xFF101828),
                            ),
                          ),
                        ),

                        const SizedBox(height: 17),

                        const Text(
                          "Farm Info",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101828),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _label("Farm Size"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _farmSizeController,
                          validator: _requiredValidator,
                          decoration: _dec(),
                        ),

                        const SizedBox(height: 20),

                        _label("Type of Crops / Plants"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cropTypesController,
                          validator: _requiredValidator,
                          decoration: _dec(),
                        ),

                        const SizedBox(height: 20),

                        _label("Soil Type"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _soilTypeController,
                          validator: _requiredValidator,
                          decoration: _dec(),
                        ),

                        const SizedBox(height: 20),

                        _label("Planting Date"),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _showCalendar = !_showCalendar);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 23,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    _formattedDate,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF101828),
                                    ),
                                  ),
                                ),
                                if (_selectedDate != null)
                                  InkWell(
                                    onTap: () {
                                      setState(() => _selectedDate = null);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFB0B0B0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        if (_showCalendar) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: CalendarDatePicker(
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                              onDateChanged: (date) {
                                setState(() {
                                  _selectedDate = date;
                                  _showCalendar = false;
                                });
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        _label("Irrigation Type"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _irrigationTypeController,
                          validator: _requiredValidator,
                          decoration: _dec(),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          height: 55,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitFarmInfo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB5DD47),
                              disabledBackgroundColor:
                                  const Color(0xFFB5DD47).withOpacity(0.55),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    "Save",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
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
            ),
          ],
        ),
      ),
    );
  }
}