import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../application/cubit/auth_cubit.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Hiện thông báo lỗi nếu đăng nhập thất bại
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo Icon Gold
                _buildLogo(),
                const SizedBox(height: 40),

                // Welcome Text
                const Text(
                  "Welcome back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in to keep the moments coming.",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                ),

                const SizedBox(height: 48),

                // Email Input
                _buildInputLabel("EMAIL"),
                _buildTextField(
                  _emailController,
                  "riley@glimpse.app",
                  Icons.email_outlined,
                ),

                const SizedBox(height: 24),

                // Password Input
                _buildInputLabel("PASSWORD"),
                _buildTextField(
                  _passwordController,
                  "••••••••",
                  Icons.lock_outline,
                  isPass: true,
                ),

                const SizedBox(height: 16),
                _buildRememberAndForgot(),

                const SizedBox(height: 60),

                // Sign In Button with Glow
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return _buildSignInButton(state is AuthLoading);
                  },
                ),

                const SizedBox(height: 32),

                // Register Link
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.visibility, color: Colors.black, size: 48),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPass = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          suffixIcon: isPass
              ? const Icon(Icons.visibility_off_outlined, color: Colors.white24)
              : null,
        ),
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: true,
                onChanged: (v) {},
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Remember me",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        const Text(
          "Forgot?",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        onPressed: isLoading
            ? null
            : () {
                context.read<AuthCubit>().signIn(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
              },
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
                "Sign In",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPage()),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.white70, fontSize: 15),
          children: [
            TextSpan(text: "New here? "),
            TextSpan(
              text: "Create account",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
