import 'package:flutter/material.dart';
import 'package:gardproject/Api/auth_service.dart';
import 'package:gardproject/Auth/farminfo.dart';
import 'package:gardproject/Auth/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hidePass = true;
  bool _hideConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _fullNameValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Full name is required";
    if (value.length < 3) return "Enter a valid full name";
    return null;
  }

  String? _emailValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Email is required";

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";

    return null;
  }

  String _normalizePhone(String value) {
    String phone = value.trim();

    phone = phone.replaceAll(" ", "");
    phone = phone.replaceAll("-", "");
    phone = phone.replaceAll("(", "");
    phone = phone.replaceAll(")", "");

    if (phone.startsWith("+20")) {
      phone = "0${phone.substring(3)}";
    } else if (phone.startsWith("20") && phone.length == 12) {
      phone = "0${phone.substring(2)}";
    }

    return phone;
  }

  String? _phoneValidator(String? v) {
    final raw = (v ?? "").trim();
    if (raw.isEmpty) return "Phone number is required";

    final phone = _normalizePhone(raw);

    final phoneRegex = RegExp(r'^01[0-9]{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      return "Enter a valid phone number";
    }

    return null;
  }

  String? _passwordValidator(String? v) {
    final value = (v ?? "").trim();

    if (value.isEmpty) return "Password is required";
    if (value.length < 8) return "Password must be at least 8 characters";

    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasDigit) return "Add at least 1 number";

    return null;
  }

  String? _confirmValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Confirm password is required";
    if (value != _passController.text.trim()) return "Passwords do not match";
    return null;
  }

  Future<void> _onNext() async {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.register(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _normalizePhone(_phoneController.text),
        password: _passController.text.trim(),
        confirmPassword: _confirmController.text.trim(),
        language: "en",
      );

      if (!mounted) return;

      if (result["success"] == true) {
        final debugToken = result["data"]?["debugVerifyToken"];

if (debugToken != null && debugToken.toString().isNotEmpty) {
  await _authService.verifyEmail(token: debugToken.toString());
}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Register successful"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Farminfo(
              email: _emailController.text.trim(),
              debugVerifyToken: result["data"]?["debugVerifyToken"],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Register failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Register failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.6),
      ),
    );
  }

  InputDecoration _passwordDecoration({
    required String hint,
    required bool hidden,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA3AF),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: const Color(0xFF9AA3AF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFD1D5DB),
          width: 1.4,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF98A2B3),
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE11D48),
          width: 1.4,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE11D48),
          width: 1.6,
        ),
      ),
    );
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
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(10),
                                child:  Padding(
                                  padding: EdgeInsets.fromLTRB(10,10,0,0),
                                  child:    const Icon(Icons.arrow_back_outlined,size: 24,)
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Padding(
                                padding: EdgeInsets.only(left: 13),
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Already have an account? ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF6C7278),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const Login(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF272D22),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Full Name",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: _fullNameController,
                                decoration: _inputDecoration("Enter your name"),
                                validator: _fullNameValidator,
                              ),
                              const SizedBox(height: 15),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Email",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration(".....@gmail.com"),
                                validator: _emailValidator,
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Phone Number",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration("(+20) 10XXXXXXXX"),
                                validator: _phoneValidator,
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Password",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: _passController,
                                obscureText: _hidePass,
                                decoration: _passwordDecoration(
                                  hint: "*******",
                                  hidden: _hidePass,
                                  onToggle: () =>
                                      setState(() => _hidePass = !_hidePass),
                                ),
                                validator: _passwordValidator,
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Confirm Password",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _hideConfirm,
                                decoration: _passwordDecoration(
                                  hint: "*******",
                                  hidden: _hideConfirm,
                                  onToggle: () => setState(
                                    () => _hideConfirm = !_hideConfirm,
                                  ),
                                ),
                                validator: _confirmValidator,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 60,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _onNext,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB5DD47),
                                    disabledBackgroundColor:
                                        const Color(0xFFB5DD47),
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
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Text(
                                          "Next",
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
    );
  }
}