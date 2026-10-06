import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../splash/splash_page.dart';
import 'forgot_password_page.dart';
import 'otp_page.dart';
import 'register_page.dart';

/// Phone + password sign-in.
///
/// If the account has no password the backend answers
/// "No password set. Login with OTP instead." — that error is intercepted here
/// and the flow continues straight into the OTP screen rather than dead-ending.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.onAuthenticated});

  /// Optional callback so the page can be embedded (e.g. in a test harness).
  final VoidCallback? onAuthenticated;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final String? last = ref.read(appPreferencesProvider).lastPhone;
    if (last != null) _phone.text = _pretty(last);
  }

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  String _pretty(String phone) => phone.startsWith('250')
      ? '0${phone.substring(3)}'
      : phone;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signIn(
            phone: _phone.text.trim(),
            password: _password.text,
          );
      widget.onAuthenticated?.call();
    } on ApiException catch (e) {
      if (e.message.toLowerCase().contains('otp')) {
        if (mounted) await _continueWithOtp();
        return;
      }
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueWithOtp() async {
    final String phone = _phone.text.trim();
    try {
      final OtpDispatch dispatch =
          await ref.read(sessionProvider.notifier).sendOtp(phone);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext _) => OtpPage(phone: phone, dispatch: dispatch),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _forgot() async {
    final String phone = _phone.text.trim();
    if (Validators.phone(phone) != null) {
      setState(() => _error = 'Enter your phone number first');
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext _) => const ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BrandMark(size: 52),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Welcome back', style: theme.textTheme.displayMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sign in to rent equipment or manage your listings.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
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
                  label: 'Password',
                  controller: _password,
                  obscure: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  validator: (String? v) =>
                      (v ?? '').isEmpty ? 'Enter your password' : null,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _busy ? null : _forgot,
                    child: const Text('Forgot password?'),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _ErrorBanner(message: _error!),
                ],
                const SizedBox(height: AppSpacing.md),
                NeoButton(
                  label: 'Sign in',
                  loading: _busy,
                  onPressed: _busy ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.sm),
                NeoButton(
                  label: 'Use a one-time code instead',
                  variant: NeoButtonVariant.secondary,
                  onPressed: _busy ? null : _continueWithOtp,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('New to Neo?', style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext _) => const RegisterPage(),
                                ),
                              ),
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.danger),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared by register/login/forgot so error styling stays consistent.
class NeoErrorBanner extends StatelessWidget {
  const NeoErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => _ErrorBanner(message: message);
}

/// Formats an OTP dispatch banner, including the dev code when present.
class OtpNotice extends StatelessWidget {
  const OtpNotice({super.key, required this.phone, this.dispatch});

  final String phone;
  final OtpDispatch? dispatch;

  @override
  Widget build(BuildContext context) {
    final String? code = dispatch?.devOtp;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sms_rounded, size: 18, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We sent a 6-digit code to ${Validators.normalisePhone(phone)}',
                  style: AppTypography.bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                if (code != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text('Development code: ',
                          style: AppTypography.bodySmall),
                      Text(
                        code,
                        style: AppTypography.titleMedium
                            ?.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Relative countdown used on the OTP screen ("Resend in 42s").
class ResendCountdown extends StatefulWidget {
  const ResendCountdown({
    super.key,
    required this.seconds,
    required this.onResend,
    this.label = 'Resend code',
  });

  final int seconds;
  final VoidCallback onResend;
  final String label;

  @override
  State<ResendCountdown> createState() => _ResendCountdownState();
}

class _ResendCountdownState extends State<ResendCountdown> {
  late int _remaining = widget.seconds;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    _remaining--;
    if (!mounted) return;
    if (_remaining <= 0) {
      setState(() => _remaining = 0);
      return;
    }
    setState(() {});
    Future<void>.delayed(const Duration(seconds: 1), _tick);
  }

  @override
  Widget build(BuildContext context) {
    final bool ready = _remaining <= 0;
    return TextButton(
      onPressed: ready ? widget.onResend : null,
      child: Text(
        ready ? widget.label : '${widget.label} in ${_remaining}s',
      ),
    );
  }
}

/// Small helper so pages can format a timestamp consistently.
String stamp(DateTime time) => '${Dates.short(time)} · ${Dates.time(time)}';