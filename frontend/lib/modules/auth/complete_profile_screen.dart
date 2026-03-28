import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/snackbar_helper.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  bool _needsName = true;
  bool _needsEmail = true;
  bool _needsPhone = true;

  @override
  void initState() {
    super.initState();
    final storage = Get.find<StorageService>();
    final userData = storage.readUserData();
    if (userData != null) {
      final name = userData['name'] as String?;
      final email = userData['email'] as String?;
      final phone = userData['phone'] as String?;

      if (name != null && name.isNotEmpty) {
        _nameCtrl.text = name;
        _needsName = false;
      }
      if (email != null && email.isNotEmpty) {
        _emailCtrl.text = email;
        _needsEmail = false;
      }
      if (phone != null && phone.isNotEmpty) {
        _phoneCtrl.text = phone;
        _needsPhone = false;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _allFilled =>
      !_needsName && !_needsEmail && !_needsPhone;

  int get _fieldsNeeded =>
      (_needsName ? 1 : 0) + (_needsEmail ? 1 : 0) + (_needsPhone ? 1 : 0);

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showErrorSnack('Name is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = Get.find<ApiClient>();
      await client.safePut(ApiEndpoints.updateProfile, {
        'name': name,
        'email': _emailCtrl.text.trim().isNotEmpty
            ? _emailCtrl.text.trim()
            : null,
        'phone': _phoneCtrl.text.trim().isNotEmpty
            ? _phoneCtrl.text.trim()
            : null,
      });

      // Update local storage
      final storage = Get.find<StorageService>();
      final existing = storage.readUserData() ?? {};
      existing['name'] = name;
      if (_emailCtrl.text.trim().isNotEmpty) {
        existing['email'] = _emailCtrl.text.trim();
      }
      if (_phoneCtrl.text.trim().isNotEmpty) {
        existing['phone'] = _phoneCtrl.text.trim();
      }
      storage.saveUserData(existing);

      Get.offAllNamed(AppRoutes.home);
    } catch (_) {
      showErrorSnack('Failed to save profile');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If all fields are already filled, skip this screen
    if (_allFilled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.home);
      });
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(RenewdSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: RenewdSpacing.xxl),
              Text('Complete Your Profile',
                  style: RenewdTextStyles.h1
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: RenewdSpacing.sm),
              Text(
                'Just ${_fieldsNeeded == 1 ? 'one more thing' : 'a few details'} to get you started',
                style: RenewdTextStyles.body
                    .copyWith(color: RenewdColors.slate),
              ),
              const SizedBox(height: RenewdSpacing.xxl),

              // Name (always show, pre-filled if available)
              _FieldLabel(label: 'Name', required: true),
              const SizedBox(height: RenewdSpacing.sm),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Your full name',
                  prefixIcon: Icon(LucideIcons.user,
                      size: 18, color: RenewdColors.slate),
                ),
              ),

              // Email (show if missing)
              if (_needsEmail) ...[
                const SizedBox(height: RenewdSpacing.xl),
                _FieldLabel(label: 'Email'),
                const SizedBox(height: RenewdSpacing.sm),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'your@email.com',
                    prefixIcon: Icon(LucideIcons.mail,
                        size: 18, color: RenewdColors.slate),
                  ),
                ),
              ],

              // Phone (show if missing)
              if (_needsPhone) ...[
                const SizedBox(height: RenewdSpacing.xl),
                _FieldLabel(label: 'Phone'),
                const SizedBox(height: RenewdSpacing.sm),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+91 9876543210',
                    prefixIcon: Icon(LucideIcons.phone,
                        size: 18, color: RenewdColors.slate),
                  ),
                ),
              ],

              const SizedBox(height: RenewdSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: RenewdTextStyles.bodySmall
                .copyWith(color: RenewdColors.slate)),
        if (required)
          Text(' *',
              style: RenewdTextStyles.bodySmall
                  .copyWith(color: RenewdColors.coralRed)),
      ],
    );
  }
}
