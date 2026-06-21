import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gardproject/service/profile_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String fullName;
  final String email;
  final String phoneNumber;

  const ProfileUpdateScreen({
    super.key,
    required this.onBack,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _isUpdating = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  static const bg = Color(0xFFF3F4F6);
  static const muted = Colors.grey;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.fullName;
    _emailCtrl.text = widget.email;
    _phoneCtrl.text = widget.phoneNumber;
    _passCtrl.text = "";
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _onUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    final result = await _profileService.updateProfile(
      fullName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result["success"] != true) {
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"]?.toString() ?? "Update failed",
          ),
        ),
      );
      return;
    }

    if (_selectedImage != null) {
      final imageResult = await _profileService.updateProfileImage(
        _selectedImage!,
      );

      if (!mounted) return;

      if (imageResult["success"] != true) {
        setState(() {
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              imageResult["message"]?.toString() ??
                  "Failed to update profile image",
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Updated")),
    );

    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
           icon:        const Icon(Icons.arrow_back_outlined,size: 24,),
          onPressed: widget.onBack,
        ),
        centerTitle: true,
        title: const Text(
          "Profile update",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFB5DD47),
                                      width: 4,
                                    ),
                                    color: const Color(0xFFEDEDED),
                                  ),
                                  child: ClipOval(
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 58,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: InkWell(
                                    onTap: _pickImage,
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Color(0xFFB5DD47),
                                          width: 2.5,
                                        ),
                                      ),
                                     child: Center(
  child: SvgPicture.asset(
    'images/lucide--pen-line.svg',
    width: 20,
    height: 20,
    
    color: Color(0xFFB5DD47),
  ),
),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _nameCtrl.text.isEmpty ? "No Name" : _nameCtrl.text,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _emailCtrl.text,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB5DD47),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _Label("Name"),
                        _WhiteField(
                          controller: _nameCtrl,
                          hint: "Ali Ahmed",
                          keyboardType: TextInputType.name,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        const _Label("Email"),
                        _WhiteField(
                          controller: _emailCtrl,
                          hint: "aliahmedd@gmail.com",
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final value = (v ?? "").trim();
                            if (value.isEmpty) return "Email is required";
                            final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(value);
                            if (!ok) return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        const _Label("Phone Number"),
                        _WhiteField(
                          controller: _phoneCtrl,
                          hint: "01090203434",
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            final value = (v ?? "").trim();
                            if (value.isEmpty) return "Phone is required";
                            if (value.length < 10) return "Phone is too short";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        const _Label("Password"),
                        _WhiteField(
                          controller: _passCtrl,
                          hint: "********",
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _obscure,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: muted,
                            ),
                          ),
                          validator: (v) {
                            final value = (v ?? "");
                            if (value.isEmpty) return "Password is required";
                            if (value.length < 6) return "Min 6 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _onUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFB5DD47),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: _isUpdating
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    "Update",
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
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _WhiteField extends StatelessWidget {
  const _WhiteField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFB0B0B0),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
      ),
    );
  }
}