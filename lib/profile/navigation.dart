import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gardproject/profile/farm_home_screen.dart';
import 'package:gardproject/profile/profile.dart';
import 'package:gardproject/profile/recomm.dart';
import 'package:gardproject/profile/scan.dart';
import 'package:gardproject/profile/weather.dart';
import 'package:gardproject/profile/edit.dart';
import 'package:gardproject/profile/language.dart';
import 'package:gardproject/profile/farminfo.dart';

enum ProfileSection {
  main,
  editProfile,
  language,
  farmInfo,
}


class Navigation extends StatefulWidget {
  final int startIndex;

  const Navigation({
    super.key,
    this.startIndex = 0,
  });

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late int index;
  ProfileSection profileSection = ProfileSection.main;

  @override
  void initState() {
    super.initState();
    index = widget.startIndex;
  }

  String _fullName = "";
  String _email = "";
  String _phoneNumber = "";

  Widget navItem({
    required String asset,
    required String label,
    required bool isActive,
  }) {
    const pageBg = Colors.transparent;

    return SizedBox(
      width: 72,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: isActive ? 8 : 18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isActive ? 58 : 32,
                  height: isActive ? 58 : 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? pageBg : Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      width: isActive ? 70 : 42,
                      height: isActive ? 70 : 42,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFB5DD47)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          asset,
                          width: isActive ? 30 : 27,
                          height: isActive ? 30 : 27,
                          colorFilter: const ColorFilter.mode(
                            Colors.black87,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    switch (profileSection) {
      case ProfileSection.editProfile:
        return ProfileUpdateScreen(
          onBack: () {
            setState(() {
              profileSection = ProfileSection.main;
            });
          },
          fullName: _fullName,
          email: _email,
          phoneNumber: _phoneNumber,
        );

      case ProfileSection.language:
        return LanguagePage(
          onBack: () {
            setState(() {
              profileSection = ProfileSection.main;
            });
          },
        );

      case ProfileSection.farmInfo:
        return FarmInfoUpdateScreen(
          onBack: () {
            setState(() {
              profileSection = ProfileSection.main;
            });
          },
        );

      case ProfileSection.main:
        return ProfilePage(
          onEditProfile: (fullName, email, phoneNumber) async {
            setState(() {
              _fullName = fullName;
              _email = email;
              _phoneNumber = phoneNumber;
              profileSection = ProfileSection.editProfile;
            });
          },
          onLanguageTap: () {
            setState(() {
              profileSection = ProfileSection.language;
            });
          },
          onFarmInfoTap: () {
            setState(() {
              profileSection = ProfileSection.farmInfo;
            });
          },
        );
    }
  }

  
  

  List<Widget> get pages => [
  const FarmHomeScreen(),
  const WeatherScreen(),
const ScanOverviewScreen(),
RecommendationsScreen(key: ValueKey(index)),
  _buildProfileSection(),
];
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      navItem(
        asset: "images/hugeicons--home-01 (1).svg",
        label: "Home",
        isActive: index == 0,
      ),
      navItem(
        asset: "images/fluent--weather-hail-day-24-regular.svg",
        label: "Weather",
        isActive: index == 1,
      ),
      navItem(
        asset: "images/mage--scan.svg",
        label: "Scan",
        isActive: index == 2,
      ),
      navItem(
        asset: "images/hugeicons--notification-01.svg",
        label: "RECM",
        isActive: index == 3,
      ),
      navItem(
        asset: "images/f7--person.svg",
        label: "Profile",
        isActive: index == 4,
      ),
    ];
final bool hideNavBar =
    index == 4 && profileSection != ProfileSection.main;
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEF4),
      body: IndexedStack(
        index: index,
        children: pages,
      ),
 bottomNavigationBar: hideNavBar
    ? const SizedBox.shrink()
    : CurvedNavigationBar(
        index: index,
        height: 75,
        items: items,
        color: Colors.white,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (newIndex) {
          setState(() {
            index = newIndex;

            if (newIndex != 4) {
              profileSection = ProfileSection.main;
            }
          });
        },
      ),
      
    );
  }
}
