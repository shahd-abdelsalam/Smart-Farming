import 'package:flutter/material.dart';
import 'package:gardproject/Auth/verifycode.dart';
import 'package:gardproject/Api/auth_service.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA3AF),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF98A2B3), width: 1.6),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.forgotPassword(email: email);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Code sent')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
         builder: (_) => CheckYourEmail(
  email: email,
),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Request failed')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("images/design.png", fit: BoxFit.cover),
          ),
         SafeArea(
  child: Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(10),
                                child:  Padding(
                                  padding: EdgeInsets.fromLTRB(0,10,0,0),
                                  child:  const Icon(Icons.arrow_back_outlined,size: 24,)
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Image.asset(
                                  "images/Two_factor_authentication-bro_1.png",
                                  height: 320,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) =>
                                      const SizedBox(height: 210),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Forget Password",
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Please enter your email to reset the password",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6C7278),
                                ),
                              ),
                              const SizedBox(height: 27),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Email",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration("......@gmail.com"),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 60,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleResetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB5DD47),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Text(
                                          "Reset Password",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
        ),  ),]),); } 
              }