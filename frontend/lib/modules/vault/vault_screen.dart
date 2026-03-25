import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'vault_controller.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(VaultController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
      ),
      body: Center(
        child: Text(
          'Your documents will appear here',
          style: MinderTextStyles.body.copyWith(color: MinderColors.slate),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'vault_fab',
        onPressed: () {},
        backgroundColor: MinderColors.oceanBlue,
        foregroundColor: Colors.white,
        child: const Icon(Iconsax.scan),
      ),
    );
  }
}
