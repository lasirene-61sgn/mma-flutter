
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../main.dart';
import '../riverpod/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passWordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _validateFields = false;

  // Scenario tracker: 'continue', 'otp', or 'none'
  String _activeScenario = 'none';

  @override
  void dispose() {
    _mobileController.dispose();
    _passWordController.dispose();
    super.dispose();
  }

  // SCENARIO 1: Full Validation (Mobile + Password)
  Future<void> _handleContinue() async {
    setState(() {
      _activeScenario = 'continue';
      _validateFields = true;
    });

    if (!_formKey.currentState!.validate()) return;

    await ref.read(loginProvider.notifier).login({
      "mobile": _mobileController.text.trim(),
      "password": _passWordController.text,
    }, mobile: _mobileController.text.trim());
  }

  // SCENARIO 2: Mobile Validation Only
  Future<void> _handleFirstTimeUser() async {
    setState(() {
      _activeScenario = 'otp';
      _validateFields = true;
    });

    if (!_formKey.currentState!.validate()) return;

    final mobile = _mobileController.text.trim();
    await ref.read(loginProvider.notifier).registerOtpRequest(
        "api/customer/send-otp", {"mobile": mobile},
        mobile: mobile, isFirstTime: true);
  }

  Future<void> _handleForgetUser() async {
    setState(() {
      _activeScenario = 'otp';
      _validateFields = true;
    });

    if (!_formKey.currentState!.validate()) return;

    final mobile = _mobileController.text.trim();
    await ref.read(loginProvider.notifier).forgotFlowRequest(
        "api/customer/forgot-password-otp", {"mobile": mobile},
        mobile: mobile, isPasswordReset: true);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: MMPApp.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: _validateFields
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: MMPApp.borderBrown, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: MMPApp.maroon.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/mmp_logo.jpeg',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Welcome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: MMPApp.maroon,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mobile Number Field
                        const Text(
                          'Mobile Number',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MMPApp.maroon),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            hintText: 'Enter 10-digit mobile number',
                            prefixIcon: const Icon(Icons.phone_android, color: MMPApp.maroon),
                            prefixText: '+91 ',
                            counterText: '',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: MMPApp.maroon, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter mobile number';
                            if (value.length != 10) return 'Mobile number must be 10 digits';
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Please enter valid numbers only';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        const Text(
                          'Password',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MMPApp.maroon),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passWordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outlined, color: MMPApp.maroon),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: MMPApp.maroon, width: 2),
                            ),
                          ),
                          validator: (value) {
                            // Only validate password for 'continue' scenario
                            if (_activeScenario == 'continue') {
                              if (value == null || value.isEmpty) return 'Please enter password';
                              if (value.length < 6) return 'Password must be 6 digits above';
                            }
                            return null;
                          },
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: loginState.isForgotLoading ? null : _handleForgetUser,
                            child: loginState.isForgotLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: MMPApp.maroon),
                                  )
                                : const Text(
                                    'Forgot Password?',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: MMPApp.maroon),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loginState.isLoading ? null : _handleContinue,
                            child: loginState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'CONTINUE',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // First Time User
                        Center(
                          child: TextButton.icon(
                            onPressed: loginState.isOtpLoading ? null : _handleFirstTimeUser,
                            icon: loginState.isOtpLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: MMPApp.maroon),
                                  )
                                : const Icon(Icons.person_add),
                            label: const Text('First Time User? Register with OTP'),
                            style: TextButton.styleFrom(foregroundColor: MMPApp.maroon),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
