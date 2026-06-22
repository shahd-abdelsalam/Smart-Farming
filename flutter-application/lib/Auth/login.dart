import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gardproject/Api/auth_service.dart';
import 'package:gardproject/Auth/forgetpass.dart';
import 'package:gardproject/Auth/signup.dart';
import 'package:gardproject/permission/location_permission_osm_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool rememberMe = false;
  bool _hidePass = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
    
  }
  bool _isLoginSuccess(dynamic result) {
  if (result == null || result is! Map) return false;

  final successFlag = result["success"] == true;
  final hasToken =
      result["data"]?["token"] != null ||
      result["token"] != null ||
      result["accessToken"] != null ||
      result["data"]?["accessToken"] != null;

  return successFlag && hasToken;
}

String _extractMessage(dynamic result) {
  if (result is Map) {
    return result["message"]?.toString() ??
        result["error"]?.toString() ??
        "Something went wrong";
  }
  return "Something went wrong";
}

  Future<void> _handleLogin() async {
    if (!rememberMe) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Click on Remember me"),
      backgroundColor: Colors.red,
    ),
  );
  return;
}
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (_isLoginSuccess(result)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _extractMessage(result) == "Something went wrong"
                  ? "Login successful"
                  : _extractMessage(result),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LocationPermissionOsmScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_extractMessage(result)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: $e"),
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

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB5DD47), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      suffixIcon: suffixIcon,
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
           child:    SingleChildScrollView(
  padding: EdgeInsets.only(
    left: 25,
    right: 25,
    bottom: MediaQuery.of(context).viewInsets.bottom + 25,
  ),
  child: Column(
    children: [
      const SizedBox(height: 40), 

      Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "images/Logo1.png",
                          width: 150,
                          height: 120,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Enter your Email and Password to Login",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6C7278),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(hint: "Email"),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter your email";
                            }
                            if (!RegExp(
                              r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value.trim())) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePass,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          decoration: _inputDecoration(
                            hint: "Password",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hidePass = !_hidePass;
                                });
                              },
                              icon: Icon(
                                _hidePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,color: Colors.grey,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter your password";
                            }
                            if (value.trim().length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                  const Flexible(
                                    child: Text("Remember me"),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgetPassword(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFF272D22),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 55,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB5DD47),
                              disabledBackgroundColor: const Color(0xFFB5DD47),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
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
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    SizedBox(
      width: 95, 
      child: Divider(
        thickness: 1,
        color: Colors.white,
      ),
    ),

    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "Or login with",
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF6C7278),
        ),
      ),
    ),

    SizedBox(
      width: 95, 
      child: Divider(
        thickness: 1,
        color: Colors.white,
      ),
    ),
  ],
),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
_SocialBtn(
  onTap: () {},
  child: SvgPicture.asset(
    'images/devicon--google.svg',
    width: 25,
    height: 25,
  ),
),
                            const SizedBox(width: 12),
                            _SocialBtn(
                              onTap: ()  {},
                              child:  SvgPicture.asset(
                          'images/logos--facebook.svg',width: 25,height: 25,),
                            ),
                            const SizedBox(width: 12),
                            _SocialBtn(
                              onTap: ()  {},
                              child:  SvgPicture.asset(
                          'images/ic--round-apple.svg',height: 25,width: 25,),
                            ),
                            const SizedBox(width: 12),
                            _SocialBtn(
                             onTap: ()  {},
                              child:  SvgPicture.asset(
                          'images/circum--mobile-3.svg',width: 25,height: 25,),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF6C7278),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUp(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                 
                ),
                 const SizedBox(height: 40), 
          ],  ),
            ),
          ),
          
        ),  ],
        
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialBtn({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(0),
      child: Container(
        height: 50,
        width: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: Colors.white,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
} 