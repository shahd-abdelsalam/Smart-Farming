import 'package:flutter/material.dart';
import 'package:gardproject/Auth/login.dart';
import 'package:url_launcher/url_launcher.dart';

class Confirmation extends StatefulWidget {
  final String email;

  const Confirmation({
    super.key,
    required this.email,
  });

  @override
  State<Confirmation> createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  bool _isOpeningGmail = false;

  Future<void> _openGmail() async {
    setState(() {
      _isOpeningGmail = true;
    });

    try {
      final Uri gmailUri = Uri.parse("https://mail.google.com/");

      final opened = await launchUrl(
        gmailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't open Gmail"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error opening Gmail: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningGmail = false;
        });
      }
    }
  }

  void _goToLogin() {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const Login(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),

                      const Text(
                        "Confirm Your Email",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "We sent a verification link to:\n${widget.email}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Open Gmail, click the verification link,\nthen come back and continue.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Image.asset(
                        "images/Sent_Message-bro_1.png",
                        width: double.infinity,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isOpeningGmail ? null : _openGmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB5DD47),
                          ),
                          child: _isOpeningGmail
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : const Text(
                                  "Open Gmail",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _goToLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const Text(
                            "I Verified, Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
    );
  }
}