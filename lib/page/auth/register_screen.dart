import 'package:chatai/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final auth = ref.read(authNotifierProvider.notifier);

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 5,
          children: [
            Center(
              child: Text(
                "Registrasi",
                style: GoogleFonts.robotoCondensed(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                "Silahkan registrasi terlebih dahulu.",
                style: GoogleFonts.robotoCondensed(fontSize: 14),
              ),
            ),
            SizedBox(height: 20),

            TextFormField(
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.robotoCondensed(fontSize: 14),
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email tidak boleh kosong";
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 10),
            Consumer(
              builder: (context, ref, _) {
                final securePassword = ref.watch(securePasswordProvider);
                return TextFormField(
                  obscureText: securePassword,
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  style: GoogleFonts.robotoCondensed(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      onPressed: () {
                        ref
                            .read(securePasswordProvider.notifier)
                            .state = !securePassword;
                      },
                      icon: Icon(
                        securePassword ? Iconsax.eye : Iconsax.eye_slash,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                  await auth.signUpManual(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                },
                icon: const Icon(Iconsax.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                label: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Register"),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sudah punya akun?"),
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
