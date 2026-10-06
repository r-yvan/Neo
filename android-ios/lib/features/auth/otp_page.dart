import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import 'login_page.dart';
import 'otp_page.dart';

/// Six-digit code entry shared by sign-in, phone verification and password
/// reset. [onVerify] receives the code; the page pops itself on success.
class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({
    super.key,
    required this.phone,
    this.title = 'Verify your phone',
    this.subtitle,
    this.dispatch,
    this.onVerify,
    this.onVerified,
    this.showResend = true,
    this.autoVerify = true,
  });

  final String phone;
  final String title;
  final String? subtitle;
  final OtpDispatch? dispatch;
  final Future<void> Function(String otp)? onVerify;
  final VoidCallback? onVerified;
  final bool showResend;
  final bool autoVerify;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final TextEditingController _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.autoVerify && widget.dispatch?.devOtp != null) {
      // Nothing to prefill — the dev code is only displayed, never auto-typed,
      // so the manual entry path stays exercised during development.
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final String value = _code.text.trim();
    final String? invalid = Validators.otp(value);
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.onVerify != null) {
        await widget.onVerify!(value);
      } else {
        await ref.read(sessionProvider.notifier).verifyOtp(
              phone: widget.phone,
              otp: value,
            );
      }
      widget.onVerified?.call();
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _error = null);
    try {
      final OtpDispatch dispatch =
          await ref.read(sessionProvider.notifier).sendOtp(widget.phone);
      if (mounted) {
        showNeoSnack(context, 'A new code has been sent', icon: Icons.sms_rounded);
        setState(() {});
        // Re-nudge the countdown by rebuilding with a fresh dispatch.
        _latest = dispatch;
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  OtpDispatch? _latest;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final OtpDispatch? dispatch = _latest ?? widget.dispatch;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(widget.title, style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.subtitle ??
                    'Enter the code we sent to your phone to continue.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              OtpNotice(phone: widget.phone, dispatch: dispatch),
              const SizedBox(height: AppSpacing.xl),
              OtpInput(controller: _code, onCompleted: (_) {
                if (!_busy) _verify();
              }),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                NeoErrorBanner(message: _error!),
              ],
              const SizedBox(height: AppSpacing.xl),
              NeoButton(
                label: 'Verify',
                loading: _busy,
                onPressed: _busy ? null : _verify,
              ),
              if (widget.showResend) ...[
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: ResendCountdown(
                    seconds: dispatch?.expiresInMinutes ?? 10,
                    onResend: _resend,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}