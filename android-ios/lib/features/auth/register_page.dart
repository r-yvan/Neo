import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/providers.dart';
import 'otp_page.dart';

/// Registration. `POST /auth/register` creates the account with the RENTER
/// role and returns tokens plus a fresh OTP, so the user lands in the
/// verification screen immediately.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _nationalId = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _nationalId.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).register(
            phone: _phone.text.trim(),
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            nationalId: _nationalId.text.trim(),
            password: _password.text,
          );
      if (mounted) {
        // Registered and signed in — the router redirects to /home.
        showNeoSnack(context, 'Welcome to Neo, ${_name.text.trim().split(' ').first}!');
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Create your account', style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Rent with your phone number. You can add a national ID later to list your own equipment.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                NeoField(
                  label: 'Full name',
                  hint: 'Jean Uwimana',
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: Validators.fullName,
                ),
                const SizedBox(height: AppSpacing.md),
                NeoField(
                  label: 'Phone number',
                  hint: '0780000000',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_iphone_rounded,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  validator: Validators.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                NeoField(
                  label: 'Email (optional)',
                  hint: 'you@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                NeoField(
                  label: 'National ID (optional)',
                  hint: '16 digits',
                  controller: _nationalId,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                  validator: (String? v) =>
                      (v ?? '').trim().isEmpty ? null : Validators.nationalId(v),
                ),
                const SizedBox(height: AppSpacing.md),
                NeoField(
                  label: 'Password',
                  hint: 'At least 6 characters',
                  controller: _password,
                  obscure: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  validator: (String? v) => Validators.password(v, required: false),
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  NeoErrorBanner(message: _error!),
                ],
                const SizedBox(height: AppSpacing.lg),
                NeoButton(
                  label: 'Create account',
                  loading: _busy,
                  onPressed: _busy ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.sm),
                NeoButton(
                  label: 'I already have an account',
                  variant: NeoButtonVariant.ghost,
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}