import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/register_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _cpassController = TextEditingController();
  final _referralController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _cpassController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the Terms & Conditions to proceed.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<RegisterProvider>().initiatePhoneRegistration(
            firstName: _fnameController.text.trim(),
            lastName: _lnameController.text.trim(),
            rawPhone: _phoneController.text.trim(),
            password: _passController.text,
            referral: _referralController.text.trim(),
          );
    }
  }

  void _showOtpUiDialog() {
    final provider = context.read<RegisterProvider>();
    final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
    final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Verify OTP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Consumer<RegisterProvider>(
            builder: (context, prov, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("OTP sent to +91${_phoneController.text}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 35,
                        child: TextField(
                          controller: otpControllers[index],
                          focusNode: focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: Alignment.center,
                          maxLength: 1,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: const InputDecoration(counterText: "", enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
                          onChanged: (val) {
                            if (val.length == 1 && index < 5) {
                              focusNodes[index + 1].requestFocus();
                            }
                            if (val.isEmpty && index > 0) {
                              focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  prov.timerSeconds > 0
                      ? Text("Resend in ${prov.timerSeconds}s", style: const TextStyle(color: Colors.amber, fontSize: 13))
                      : TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _onSignUpPressed();
                          },
                          child: const Text("Resend OTP", style: TextStyle(color: Color(0xFF38BDF8))),
                        ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
              onPressed: () {
                final code = otpControllers.map((c) => c.text).join();
                if (code.length == 6) {
                  Navigator.pop(context);
                  provider.submitManualOtp(
                    code,
                    _fnameController.text.trim(),
                    _lnameController.text.trim(),
                    "+91${_phoneController.text.trim()}",
                    _passController.text,
                    _referralController.text.trim(),
                  );
                }
              },
              child: const Text("VERIFY", style: TextStyle(color: Colors.black)),
            )
          ],
        );
      },
    );
  }

  void _showBanUiAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("ACCOUNT SUSPENDED", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text("Your account has been permanently banned.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("EXIT", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Consumer<RegisterProvider>(
        builder: (context, provider, _) {
          if (provider.state == RegisterState.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            });
          }

          if (provider.state == RegisterState.otpSent) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showOtpUiDialog();
            });
          }

          if (provider.state == RegisterState.error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (provider.errorMessage == "BANNED_USER") {
                _showBanUiAlert();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.errorMessage)),
                );
              }
            });
          }

          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Create Account",
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: Alignment.center,
                        ),
                        const SizedBox(height: 30),
                        _buildInputField(_fnameController, "First Name", Icons.person, (val) => val!.isEmpty ? "Required" : null),
                        const SizedBox(height: 16),
                        _buildInputField(_lnameController, "Last Name", Icons.person_outline, (val) => val!.isEmpty ? "Required" : null),
                        const SizedBox(height: 16),
                        _buildInputField(_phoneController, "Phone Number", Icons.phone, (val) => val!.length != 10 ? "Enter 10-digit number" : null, keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildInputField(_passController, "Password", Icons.lock, (val) => val!.length < 6 ? "Min 6 characters" : null, isObscure: true),
                        const SizedBox(height: 16),
                        _buildInputField(_cpassController, "Confirm Password", Icons.lock_clock, (val) => val != _passController.text ? "Passwords do not match" : null, isObscure: true),
                        const SizedBox(height: 16),
                        _buildInputField(_referralController, "Referral Code (Optional)", Icons.card_giftcard, null),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              activeColor: const Color(0xFF38BDF8),
                              checkColor: Colors.black,
                              onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                            ),
                            const Expanded(
                              child: Text(
                                "I accept the Terms & Conditions of Wintrix Pro",
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: provider.state == RegisterState.loading ? null : _onSignUpPressed,
                          child: Text(
                            provider.state == RegisterState.loading ? "PROCESSING..." : "SIGN UP",
                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(color: Color(0xFF38BDF8), textAlign: Alignment.center, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR", style: TextStyle(color: Colors.white38))),
                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: provider.state == RegisterState.loading ? null : () => provider.loginWithGoogle(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/24px-Google_\"G\"_logo.svg.png', height: 22),
                                const SizedBox(width: 12),
                                const Text("Continue with Google", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (provider.state == RegisterState.loading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                  ),
                )
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF38BDF8), size: 20),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        errorStyle: const TextStyle(color: Colors.redAccent),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF38BDF8))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }
}
