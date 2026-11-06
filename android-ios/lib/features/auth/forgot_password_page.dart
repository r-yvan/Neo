import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/illustrations/neo_illustration.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/providers.dart';
import 'login_page.dart' show NeoErrorBanner;
import 'otp_page.dart';

/// Two-step password reset: request an OTP, then set a new password.
///
/// `POST /auth/forgot-password` deliberately does not reveal whether an account
/// exists, so the UI never says "account not found".
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _neutralMessage;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
      _neutralMessage = null;
    });
    try {
      final String message = await ref
          .read(authRepositoryProvider)
          .forgotPassword(_phone.text.trim());
      if (!mounted) return;
      setState(() => _busy = false);
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext _) => OtpPage(
            phone: _phone.text.trim(),
            title: L10n.i.forgotTitle,
            subtitle: message,
            onVerify: _applyReset,
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _applyReset(String otp) async {
    final String? invalid = Validators.password(_newPassword, required: true);
    if (invalid != null) throw ApiException(message: invalid);

    await ref.read(authRepositoryProvider).resetPassword(
          phone: _phone.text.trim(),
          otp: otp,
          newPassword: _newPassword,
        );
    // The backend revokes every refresh token on reset.
    await ref.read(tokenStoreProvider).clear();
    if (mounted) {
      showNeoSnack(context, L10n.i.forgotChangedSnack);
      Navigator.of(context).popUntil((Route<void> route) => route.isFirst);
    }
  }

  // Held in state so the OTP screen's validator can read it.
  String _newPassword = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(s.forgotAppbarTitle, style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NeoIllustration(kind: IllustrationKind.reset, height: 190),
                const SizedBox(height: AppSpacing.md),
                Text(
                  s.forgotScreenIntro,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                NeoField(
                  label: s.fieldPhone,
                  hint: '0780000000',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_iphone_rounded,
                  textInputAction: TextInputAction.done,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  validator: Validators.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                NeoField(
                  label: s.fieldNewPasswordShort,
                  hint: s.forgotNewPasswordHint,
                  obscure: true,
                  onChanged: (String v) => _newPassword = v,
                  validator: Validators.password,
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  NeoErrorBanner(message: _error!),
                ],
                if (_neutralMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  NeoBadge(label: _neutralMessage!, tone: BadgeTone.success),
                ],
                const SizedBox(height: AppSpacing.lg),
                NeoButton(
                  label: s.forgotSendCta,
                  loading: _busy,
                  onPressed: _busy ? null : _send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
