import 'package:chatai/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);

    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User belum login')),
      );
      return;
    }

    try {
      await user.updateDisplayName(_nameController.text);
      await user.reload();

      await ref.read(authNotifierProvider.notifier).saveUserProfile(
        _nameController.text
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Belum login')),
      );
    }

    _nameController.text = user.displayName ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {
            context.go('/');
          }, icon: Icon(Icons.arrow_back),
        ),
        title: const Text("Profil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
                radius: 50,
                child: const Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _saveProfile,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
