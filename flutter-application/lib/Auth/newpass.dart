import 'package:flutter/material.dart';
import 'package:gardproject/Auth/success.dart';
import 'package:gardproject/Api/auth_service.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const SetNewPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _hidePass = true;
  bool _hideConfirm = true;
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _passwordValidator(String? v) {
    final value = (v ?? "").trim();

    if (value.isEmpty) return "Password is required";
    if (value.length < 8) return "Password must be at least 8 characters";

    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);

    if (!hasUpper) return "Add at least 1 uppercase letter";
    if (!hasLower) return "Add at least 1 lowercase letter";
    if (!hasDigit) return "Add at least 1 number";

    return null;
  }

  String? _confirmValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Confirm password is required";
    if (value != _passController.text.trim()) return "Passwords do not match";
    return null;
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required bool isPassword,
    required bool isHidden,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF98A2B3), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.8),
      ),
      suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      suffixIcon: isPassword
          ? IconButton(
              onPressed: onToggle,
              icon: Icon(
                isHidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: const Color(0xFF9AA3AF),
              ),
            )
          : null,
    );
  }

  Future<void> _onUpdate() async {

  setState(() => _submitted = true);

  final ok = _formKey.currentState?.validate() ?? false;

  if (!ok) {
    return;
  }

  final newPassword = _passController.text.trim();
  final confirmPassword = _confirmController.text.trim();



  setState(() {
    _isLoading = true;
  });

  final result = await _authService.resetPassword(
    email: widget.email,
    code: widget.code,
    newPassword: newPassword,
    confirmPassword: confirmPassword,
  );


  if (!mounted) return;

  setState(() {
    _isLoading = false;
  });

  if (result['success'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Password updated successfully')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SuccessScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Reset password failed')),
    );
  }
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
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
                                    padding: EdgeInsets.fromLTRB(0,10,0,0),
                                  child:    const Icon(Icons.arrow_back_outlined,size: 24,)
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  "Set New Password",
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Create a new password. Ensure it differs from\nprevious ones for security",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6C7278),
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Password",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passController,
                                  obscureText: _hidePass,
                                  textInputAction: TextInputAction.next,
                                  decoration: _fieldDecoration(
                                    hint: "********",
                                    isPassword: true,
                                    isHidden: _hidePass,
                                    onToggle: () => setState(() => _hidePass = !_hidePass),
                                  ),
                                  validator: _passwordValidator,
                                  onChanged: (_) {
                                    if (_submitted) _formKey.currentState?.validate();
                                  },
                                ),
                                const SizedBox(height: 14),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Confirm Password",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _confirmController,
                                  obscureText: _hideConfirm,
                                  textInputAction: TextInputAction.done,
                                  decoration: _fieldDecoration(
                                    hint: "********",
                                    isPassword: true,
                                    isHidden: _hideConfirm,
                                    onToggle: () =>
                                        setState(() => _hideConfirm = !_hideConfirm),
                                  ),
                                  validator: _confirmValidator,
                                  onFieldSubmitted: (_) => _onUpdate(),
                                  onChanged: (_) {
                                    if (_submitted) _formKey.currentState?.validate();
                                  },
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  height: 62,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _onUpdate,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB5DD47),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: const BorderSide(color: Colors.black, width: 1),
                                      ),
                                      elevation: 0,
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
                                            "Update Password",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ])    );
              }}
          