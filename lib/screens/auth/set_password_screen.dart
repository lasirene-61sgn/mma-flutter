import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../service/api/local_storage/shared_preference.dart';
import 'login/riverpod/login_provider.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  final String mobile;
  final bool isPasswordReset;

  const SetPasswordScreen({
    super.key,
    required this.mobile,
    this.isPasswordReset = false,
  });

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? device;

  @override
  void initState() {
    super.initState();
    device = SharedPreferencesHelper().getString("DToken") ?? '';
  }

  Future<void> _setPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = ref.read(loginProvider);
    final password = _passwordController.text;

    if (widget.isPasswordReset) {
      await ref.read(loginProvider.notifier).registerOtpRequest(
        "api/customer/reset-password",
        {
          "customer_id": state.user?.customer.id.toString(),
          "mobile": widget.mobile,
          "otp": state.otp,
          "password": password,
          "password_confirmation": _confirmPasswordController.text
        },
      );
    } else {
      await ref.read(loginProvider.notifier).registerOtpRequest(
        "api/customer/set-password",
        {
          "customer_id": state.user?.customer.id.toString(),
          "mobile": widget.mobile,
          "fcm_token": device != null ? device.toString() : '',
          "otp": state.otp,
          "password": password,
          "password_confirmation": _confirmPasswordController.text
        },
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    
    return Scaffold(
      backgroundColor: MMPApp.cream,
      appBar: AppBar(
        title: Text(widget.isPasswordReset ? 'Reset Password' : 'Set Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: MMPApp.maroon.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_outline, size: 60, color: MMPApp.maroon),
              ),
              const SizedBox(height: 24),
              Text(
                widget.isPasswordReset ? 'Reset Your Password' : 'Create Your Password',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MMPApp.maroon),
              ),
              const SizedBox(height: 8),
              Text(
                'For mobile: +91 ${widget.mobile}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
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
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: widget.isPasswordReset ? 'New Password' : 'Create Password',
                        hintText: 'Minimum 6 characters',
                        prefixIcon: const Icon(Icons.lock_outlined, color: MMPApp.maroon),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined, color: MMPApp.maroon),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isOtpLoading ? null : _setPassword,
                          child: state.isOtpLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  widget.isPasswordReset ? 'RESET PASSWORD' : 'SET PASSWORD',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                        ),
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

