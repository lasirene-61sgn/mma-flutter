import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import 'login/riverpod/login_provider.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String mobile;
  final bool isFirstTime;
  final bool isPasswordReset;

  const OTPVerificationScreen({
    super.key,
    required this.mobile,
    this.isFirstTime = false,
    this.isPasswordReset = false,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  Timer? _otpTimer;
  int _secondsRemaining = 60;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startOtpTimer();
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _isResending = true;
    });

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResending = false;
        });
      }
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.isFirstTime) {
      await ref.read(loginProvider.notifier).registerOtpRequest(
        "api/customer/verify-otp",
        {"otp": otp, "mobile": widget.mobile},
        otp: otp,
        mobile: widget.mobile,
        isFirstTime: true,
        firstVerify: true,
      );
    } else if (widget.isPasswordReset) {
      await ref.read(loginProvider.notifier).registerOtpRequest(
        "api/customer/verify-otp",
        {"otp": otp, "mobile": widget.mobile},
        otp: otp,
        mobile: widget.mobile,
        isFirstTime: true,
        firstVerify: false,
        resetPassword: true,
      );
    }
  }

  Future<void> _resendOTP() async {
    if (_isResending) return;
    
    // For password reset it might be a different endpoint depending on backend, 
    // but registerOtpRequest usually handles resend nicely via "api/customer/forgot-password-otp" or "api/customer/send-otp"
    final endpoint = widget.isPasswordReset ? "api/customer/forgot-password-otp" : "api/customer/send-otp";

    if (widget.isPasswordReset) {
      await ref.read(loginProvider.notifier).forgotFlowRequest(
        endpoint,
        {"mobile": widget.mobile},
        mobile: widget.mobile,
        isPasswordReset: true,
      );
    } else {
      await ref.read(loginProvider.notifier).registerOtpRequest(
        endpoint,
        {"mobile": widget.mobile},
        mobile: widget.mobile,
        isFirstTime: true,
      );
    }

    _startOtpTimer();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    return Scaffold(
      backgroundColor: MMPApp.cream,
      appBar: AppBar(
        title: Text(widget.isPasswordReset ? 'Reset Password OTP' : 'Verify OTP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // OTP Icon
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
                child: const Icon(Icons.security, size: 60, color: MMPApp.maroon),
              ),
              const SizedBox(height: 24),
              const Text(
                'OTP Verification',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MMPApp.maroon),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the OTP sent to +91 ${widget.mobile}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              // OTP Field
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
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter OTP',
                        hintText: '● ● ● ● ● ●',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline, color: MMPApp.maroon),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.isOtpLoading ? null : _verifyOTP,
                        child: state.isOtpLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'VERIFY OTP',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isResending
                              ? 'Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}'
                              : "Didn't receive OTP? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (!_isResending)
                          TextButton(
                            onPressed: _resendOTP,
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: MMPApp.maroon,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
