import 'package:chatai/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

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

    final securePassword = ref.watch(securePasswordProvider);
    final rememberMe = ref.watch(rememberMeProvider);

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
                "Selamat Datang",
                style: GoogleFonts.robotoCondensed(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            Center(
              child: Text(
                  "Silahkan login terlebih dahulu untuk mengakses fitur ini.",
                  style: GoogleFonts.robotoCondensed(fontSize: 16),
              ),
            ),
            SizedBox(height: 20,),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.robotoCondensed(fontSize: 16),
              controller: emailController,
              validator: (value) {
                if(value == null || value.isEmpty){
                  return "Email tidak boleh kosoong";
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: Icon(Icons.email),

              ),
            ),
            SizedBox(height: 10,),
            TextFormField(
              obscureText: securePassword,
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              style: GoogleFonts.robotoCondensed(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: Icon(Icons.key),
                suffixIcon: IconButton(onPressed: () {
                  ref.read(securePasswordProvider.notifier).state = !securePassword;
                },
                  icon: securePassword ? Icon(Iconsax.eye) : Icon(Iconsax.eye_slash),),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0)
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (val) {
                        ref.read(rememberMeProvider.notifier).state = val ?? false;
                      },
                    ),
                    Text("Selalu Ingat")
                  ],
                ),
                Text("Lupa Password?")
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton.icon(
                onPressed: authState.isLoading
                      ? null
                      : () async {
                    await auth.signInManual(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
                icon: Icon(Iconsax.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                label: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
            ),
            Row(
              children: [
                Text("Belum Punya akun?"),
                TextButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  child: Text("Daftar"),
                )
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                icon: Icon(Icons.mail),
                label: Text("Gmail"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
