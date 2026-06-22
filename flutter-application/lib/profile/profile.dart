import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gardproject/Api/api_config.dart';
import 'package:gardproject/Auth/login.dart';
import 'package:gardproject/service/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showLogoutDialogAndroid({
  required BuildContext context,
  required VoidCallback onConfirmLogout,
}) {

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Log out of your account?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 18),
            const Divider(
              height: 1,
              thickness: 2,
              color: Color.fromARGB(255, 216, 206, 206),
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Color(0xFFB5DD47),
                              fontWeight: FontWeight.w800,
                              fontSize: 23,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 2,
                    thickness: 2,
                    color: Color.fromARGB(255, 216, 206, 206),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onConfirmLogout();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            "Log out",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w800,
                              fontSize: 23,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class ProfilePage extends StatefulWidget {
  final Future<void> Function(
    String fullName,
    String email,
    String phoneNumber,
  ) onEditProfile;
  final VoidCallback onLanguageTap;
  final VoidCallback onFarmInfoTap;

  const ProfilePage({
    super.key,
    required this.onEditProfile,
    required this.onLanguageTap,
    required this.onFarmInfoTap,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = false;
  bool _isLoading = true;
  bool _isNotificationLoading = false;
  bool _isImageUploading = false;
  String? _error;

  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  String _fullName = "";
  String _email = "";
  String _phoneNumber = "";
  String? _profileImagePath;

  static const bg = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _profileService.getProfile();

    if (!mounted) return;

    if (result["success"] == true) {
      final user = result["data"]?["user"] ?? {};

      setState(() {
        _fullName = user["fullName"]?.toString() ?? "";
        _email = user["email"]?.toString() ?? "";
        _phoneNumber = user["phoneNumber"]?.toString() ?? "";
        _profileImagePath = user["profileImage"]?.toString();
        _notificationsEnabled = user["notificationsEnabled"] ?? false;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result["message"]?.toString() ?? "Failed to load profile";
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotifications(bool value) async {
    final oldValue = _notificationsEnabled;

    setState(() {
      _notificationsEnabled = value;
      _isNotificationLoading = true;
    });

    final result = await _profileService.updateNotifications(
      notificationsEnabled: value,
    );

    if (!mounted) return;

    if (result["success"] != true) {
      setState(() {
        _notificationsEnabled = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"]?.toString() ??
                "Failed to update notifications",
          ),
        ),
      );
    }

    setState(() {
      _isNotificationLoading = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _isImageUploading = true;
    });

    final result = await _profileService.updateProfileImage(
      File(picked.path),
    );

    if (!mounted) return;

    if (result["success"] == true) {
      await _loadProfile();

      
    } else {
      setState(() {
        _isImageUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"]?.toString() ?? "Failed to update profile image",
          ),
        ),
      );
    }
  }

  String? _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;

    final baseUrl = ApiConfig.baseUrl;

    if (path.startsWith("http")) return path;
    return "$baseUrl$path";
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const cardRadius = 18.0;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB5DD47)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    final imageUrl = _buildImageUrl(_profileImagePath);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(cardRadius),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 18,
                        offset: Offset(0, 10),
                        color: Color(0x12000000),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          InkWell(
                            onTap: _isImageUploading ? null : _pickAndUploadImage,
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Color(0xFFB5DD47), width: 3),
                              ),
                              child: CircleAvatar(
  radius: 37.5,
  backgroundColor: Colors.grey.shade200,
  backgroundImage:
      imageUrl != null ? NetworkImage(imageUrl) : null,
  child: _isImageUploading
      ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black,
          ),
        )
      : imageUrl == null
          ?  const Icon(
            Icons.person,
            size: 45,
            color: Color(0xFFCFCFCF),
          )
          : null,
),
                            ),
                          ),
                         
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fullName.isNotEmpty ? _fullName : "No Name",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _email.isNotEmpty ? _email : _phoneNumber,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFB5DD47),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await widget.onEditProfile(
                            _fullName,
                            _email,
                            _phoneNumber,
                          );
                          await _loadProfile();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Color(0xFFB5DD47),
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(cardRadius),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 18,
                        offset: Offset(0, 10),
                        color: Color(0x12000000),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: SvgPicture.asset(
                          'images/hugeicons--plant-02.svg',
                          width: 26,
                          height: 26,
                        ),
                        title: "Farm Info",
                        subtitle: "Make changes to your farm info",
                        onTap: widget.onFarmInfoTap,
                      ),
                      const _DividerLine(),
                      _SettingTile(
                        icon: const Icon(
                          Icons.language_outlined,
                          size: 26,
                          color: Colors.black,
                        ),
                        title: "Language",
                        subtitle: "Set language",
                        onTap: widget.onLanguageTap,
                      ),
                      const _DividerLine(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                       child: Row(
  children: [
    _IconBubble(
      icon: SvgPicture.asset(
        'images/mdi--bell-outline.svg',
        width: 24,
        height: 24,
      ),
    ),
    const SizedBox(width: 12),

    const Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notifications",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Manage your notification",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9A9A9A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),

    _isNotificationLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : Switch(
            value: _notificationsEnabled,
            onChanged: _updateNotifications,
            activeTrackColor: Color(0xFFB5DD47),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: const Color(0xFFEDEDED),
          ),
  ],
),
                      ),
                      const _DividerLine(),
                      _SettingTile(
                       icon: Transform(
  alignment: Alignment.center,
  transform: Matrix4.rotationY(0), 
  child: SvgPicture.asset(
    'images/humbleicons--logout.svg',
    width: 24,
    height: 24,
  ),
),
                        title: "Log out",
                        subtitle: "Further secure your account for safety",
                        onTap: () {
                          showLogoutDialogAndroid(
                            context: context,
                            onConfirmLogout: _logout,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _IconBubble(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF6C7278),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB5B5B5)),
          ],
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF2F2F2),
      ),
      child: Center(child: icon),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Divider(
        height: 1,
        thickness: 0,
        color: Color(0xFFF0F0F0),
      ),
    );
  }
}