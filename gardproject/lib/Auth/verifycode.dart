import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gardproject/Auth/newpass.dart';
import 'package:gardproject/Api/auth_service.dart';


class CheckYourEmail extends StatefulWidget {
  final String email;

  const CheckYourEmail({
    super.key,
    required this.email,
  });

  @override
  State<CheckYourEmail> createState() => _CheckYourEmailState();
}

class _CheckYourEmailState extends State<CheckYourEmail> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '${name[0]}***@$domain';
    }

    return '${name.substring(0, 2)}***@$domain';
  }

  Widget _otpBox({
    required int index,
    required String text,
    required bool active,
  }) {
    return InkWell(
      onTap: () {
        FocusScope.of(context).requestFocus(_otpFocus);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 58,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: active ? const Color(0xFFB5DD47) : const Color(0xFF9AA3AF),
            width: 1.8,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    final code = _otpController.text.trim();

    if (code.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 5-digit code")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.verifyResetCode(
      email: widget.email,
      code: code,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Code verified')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SetNewPasswordScreen(
            email: widget.email,
            code: code,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Invalid code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final otp = _otpController.text;
    final chars = List.generate(5, (i) => i < otp.length ? otp[i] : "");
    final activeIndex = otp.length.clamp(0, 4);

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
        padding: const EdgeInsets.all(20),
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
                                  child:   const Icon(Icons.arrow_back_outlined,size: 24,)
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                "Check Your Email",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "We sent a reset code to ${_maskEmail(widget.email)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9AA3AF),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Enter the 5 digit code that was sent",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9AA3AF),
                                ),
                              ),

                            

                              const SizedBox(height: 26),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(5, (i) {
                                  return _otpBox(
                                    index: i,
                                    text: chars[i],
                                    active: i == activeIndex,
                                  );
                                }),
                              ),

                              Offstage(
                                offstage: true,
                                child: TextField(
                                  controller: _otpController,
                                  focusNode: _otpFocus,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  maxLength: 5,
                                  showCursor: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: "",
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  onSubmitted: (_) => _verifyCode(),
                                ),
                              ),

                              const SizedBox(height: 28),

                              SizedBox(
                                height: 62,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _verifyCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB5DD47),
                                    disabledBackgroundColor:
                                        const Color(0xFFB5DD47).withOpacity(0.45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
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
                                          "Verify Code",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              Center(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6C7278),
                                    ),
                                    children: [
                                      TextSpan(text: "Haven’t got the email yet?  "),
                                      TextSpan(
                                        text: "Resend email",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF272D22),
                                        ),
                                      ),
                                    ],
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
    ] ), );
              }
        
}