/// Reusable presentation widgets.
///
/// Everything here obeys the design rules: one accent colour, true greys for
/// everything neutral, 12–16px radii, soft elevation.
library;

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

// ------------------------------------------------------------------ layout

/// Page scaffold with a large-title header, optional trailing action and a
/// consistent gutter.
class NeoScaffold extends StatelessWidget {
  const NeoScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.showBack = false,
    this.bottom,
    this.floatingActionButton,
    this.padded = true,
    this.onRefresh,
    this.bottomNavigationBar,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? leading;
  final List<Widget> actions;
  final bool showBack;
  final Widget? bottom;
  final Widget? floatingActionButton;
  final bool padded;
  final Future<void> Function()? onRefresh;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget content =
        padded ? Padding(padding: AppSpacing.screen, child: body) : body;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Back',
              )
            : leading,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.headlineMedium),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitle!, style: theme.textTheme.bodySmall),
              ),
          ],
        ),
        actions: actions,
      ),
      body: onRefresh == null
          ? SafeArea(child: content)
          : RefreshIndicator(
              onRefresh: onRefresh!,
              color: AppColors.accent,
              edgeOffset: 64,
              child: content,
            ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// A section header with an optional "see all" affordance.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineMedium),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ buttons

class NeoButton extends StatelessWidget {
  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.variant = NeoButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final NeoButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !loading;
    final Widget child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    final Widget button = switch (variant) {
      NeoButtonVariant.primary => FilledButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      NeoButtonVariant.secondary => OutlinedButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      NeoButtonVariant.ghost => TextButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

enum NeoButtonVariant { primary, secondary, ghost }

/// Compact square action used inside cards and headers.
class NeoIconButton extends StatelessWidget {
  const NeoIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.filled = false,
    this.colour,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool filled;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fg = colour ?? theme.colorScheme.onSurfaceVariant;
    final Widget button = Material(
      color: filled
          ? (colour ?? AppColors.accent).withValues(alpha: 0.10)
          : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon,
              size: 20,
              color: onPressed == null ? fg.withValues(alpha: 0.4) : fg),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

// ------------------------------------------------------------------- chips

class NeoChip extends StatelessWidget {
  const NeoChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.dense = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: selected ? AppColors.accent : theme.colorScheme.surface,
      borderRadius: AppRadii.pillAll,
      child: InkWell(
        borderRadius: AppRadii.pillAll,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: dense ? AppSpacing.sm : 14,
            vertical: dense ? 6 : 9,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadii.pillAll,
            border: Border.all(
              color: selected ? AppColors.accent : theme.colorScheme.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: dense ? 14 : 16,
                  color: selected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: (dense
                        ? theme.textTheme.labelSmall
                        : theme.textTheme.labelMedium)!
                    .copyWith(
                  color: selected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight:
                      selected ? AppFontWeight.semiBold : AppFontWeight.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------- cards

class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.card,
    this.elevated = false,
    this.border = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool elevated;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget content = Padding(padding: padding, child: child);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.lgAll,
        border: border ? Border.all(color: theme.colorScheme.outline) : null,
        boxShadow: elevated ? AppShadows.card : AppShadows.none,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.lgAll,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// A labelled statistic used across dashboards and summaries.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.caption,
    this.tone = AppColors.grey900,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? caption;
  final Color tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return NeoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: tone,
              ),
            ),
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                caption!,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------- media

/// Renders a listing image that may be either a remote URL or a local file
/// path (the API stores plain strings, so both are valid values).
class EquipmentImage extends StatelessWidget {
  const EquipmentImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = AppRadii.lg,
    this.fallbackIcon,
    this.fallbackLabel,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final IconData? fallbackIcon;
  final String? fallbackLabel;

  bool get _isLocal => source.startsWith('/') || source.startsWith('file:');

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (source.isEmpty) {
      image = _placeholder(context);
    } else if (_isLocal) {
      final String path =
          source.startsWith('file:') ? Uri.parse(source).toFilePath() : source;
      image = Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 220),
        placeholder: (_, __) => _ShimmerBox(
          width: width,
          height: height,
          radius: radius,
        ),
        errorWidget: (_, __, ___) => _placeholder(context),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image,
    );
  }

  Widget _placeholder(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            fallbackIcon ?? Icons.photo_camera_back_outlined,
            size: 26,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          if (fallbackLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                fallbackLabel!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({this.width, this.height, this.radius = AppRadii.lg});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHigh,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Circular avatar with an initials fallback and a "boosted" halo option.
class NeoAvatar extends StatelessWidget {
  const NeoAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = 44,
    this.ring = false,
  });

  final String initials;
  final String? imageUrl;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasImage ? null : AppColors.accentSoft,
        border: Border.all(
          color: ring ? AppColors.accent : Colors.transparent,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? EquipmentImage(
              source: imageUrl!, width: size, height: size, radius: size)
          : Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontWeight: AppFontWeight.semiBold,
                  fontSize: size * 0.36,
                  color: AppColors.accent,
                ),
              ),
            ),
    );
    return avatar;
  }
}

// -------------------------------------------------------------------- chips

class NeoBadge extends StatelessWidget {
  const NeoBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
    this.icon,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg) = switch (tone) {
      BadgeTone.neutral => (
          Theme.of(context).colorScheme.onSurfaceVariant,
          Theme.of(context).colorScheme.surfaceContainerHigh
        ),
      BadgeTone.accent => (AppColors.accent, AppColors.accentSoft),
      BadgeTone.success => (AppColors.success, AppColors.successSoft),
      BadgeTone.warning => (AppColors.warning, AppColors.warningSoft),
      BadgeTone.danger => (AppColors.danger, AppColors.dangerSoft),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

enum BadgeTone { neutral, accent, success, warning, danger }

// -------------------------------------------------------------- rating & meta

class RatingRow extends StatelessWidget {
  const RatingRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.size = 14,
    this.showCount = true,
  });

  final double rating;
  final int reviewCount;
  final double size;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool rated = reviewCount > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size + 2, color: AppColors.star),
        const SizedBox(width: 3),
        Text(
          rated ? rating.toStringAsFixed(1) : 'New',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: AppFontWeight.semiBold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (showCount && rated) ...[
          const SizedBox(width: 4),
          Text('(${reviewCount})', style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

/// Read-only key/value line used in receipts and detail sheets.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.emphasis = false,
    this.valueColour,
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final bool emphasis;
  final Color? valueColour;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle labelStyle =
        emphasis ? theme.textTheme.titleMedium! : theme.textTheme.bodyMedium!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: AppSpacing.md),
          valueWidget ??
              Text(
                value,
                style: (emphasis
                        ? theme.textTheme.titleMedium!
                        : theme.textTheme.titleSmall!)
                    .copyWith(
                  color: valueColour ?? theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- state blocks

class NeoEmptyState extends StatelessWidget {
  const NeoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: compact ? AppSpacing.xl : AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 60 : 76,
              height: compact ? 60 : 76,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: compact ? 26 : 32,
                color: AppColors.accent,
              ),
            ),
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
            Text(
              title,
              style: compact
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              NeoButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NeoErrorState extends StatelessWidget {
  const NeoErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return NeoEmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Could not load',
      message: message,
      actionLabel: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}

class NeoLoading extends StatelessWidget {
  const NeoLoading({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(label!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Card-shaped skeleton used while the first page loads.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 120, this.lines = 2});

  final double height;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return _ShimmerBox(height: height, radius: AppRadii.lg);
  }
}

/// Footer shown while a paginated list fetches its next page.
class ListFooterLoader extends StatelessWidget {
  const ListFooterLoader({super.key, required this.loading, this.endLabel});

  final bool loading;
  final String? endLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (!loading) {
      if (endLabel == null) return const SizedBox(height: AppSpacing.xl);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(endLabel!, style: theme.textTheme.bodySmall),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- inputs

class NeoField extends StatelessWidget {
  const NeoField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscure = false,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.onChanged,
    this.enabled = true,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      maxLines: obscure ? 1 : maxLines,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      textCapitalization: textCapitalization,
      enabled: enabled,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

/// OTP entry rendered as six separate boxes.
class OtpInput extends StatelessWidget {
  const OtpInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      autofocus: true,
      style: theme.textTheme.displayMedium?.copyWith(letterSpacing: 14),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      decoration: InputDecoration(
        hintText: '0' * length,
        hintStyle: theme.textStyleHint,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
      onChanged: (String value) {
        if (value.length == length) onCompleted?.call(value);
      },
    );
  }
}

extension on ThemeData {
  TextStyle get textStyleHint => textTheme.displayMedium!.copyWith(
        color: textTheme.bodySmall!.color,
        letterSpacing: 14,
      );
}

// -------------------------------------------------------------------- toast

void showNeoSnack(
  BuildContext context,
  String message, {
  bool isError = false,
  IconData? icon,
}) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      backgroundColor: isError
          ? AppColors.danger
          : (Theme.of(context).brightness == Brightness.dark
              ? AppColors.grey200
              : AppColors.grey900),
      content: Row(
        children: [
          Icon(
            icon ??
                (isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded),
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTheme_text(context).copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

TextStyle AppTheme_text(BuildContext context) =>
    Theme.of(context).textTheme.bodyMedium!;

// ------------------------------------------------------------------- sheet

Future<T?> showNeoSheet<T>(
  BuildContext context, {
  required Widget child,
  bool scrollable = false,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext ctx) => scrollable
          ? DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.94,
              builder: (BuildContext _, ScrollController controller) =>
                  SingleChildScrollView(controller: controller, child: child),
            )
          : Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: child,
              ),
            ),
    );

Future<bool> confirmNeo(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  minimumSize: const Size(88, 44),
                )
              : FilledButton.styleFrom(minimumSize: const Size(88, 44)),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Small rounded avatar stack placeholder for owner credibility.
class TrustRow extends StatelessWidget {
  const TrustRow(
      {super.key,
      required this.initials,
      required this.subtitle,
      this.trailing});

  final String initials;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: [
        NeoAvatar(initials: initials, size: 38),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(subtitle,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Horizontal scroller with page dots, used for listing photo carousels.
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.images,
    this.height = 260,
    this.categoryLabel,
    this.badge,
  });

  final List<String> images;
  final double height;
  final String? categoryLabel;
  final Widget? badge;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final int count = widget.images.isEmpty ? 1 : widget.images.length;
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: count,
            onPageChanged: (int i) => setState(() => _index = i),
            itemBuilder: (BuildContext context, int i) => EquipmentImage(
              source: widget.images.isEmpty ? '' : widget.images[i],
              width: double.infinity,
              height: widget.height,
              radius: 0,
              fallbackLabel: widget.images.isEmpty ? 'No photo yet' : null,
            ),
          ),
          if (widget.categoryLabel != null)
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: NeoBadge(
                label: widget.categoryLabel!,
                tone: BadgeTone.accent,
                icon: Icons.category_outlined,
              ),
            ),
          if (widget.badge != null)
            Positioned(
                top: AppSpacing.sm, right: AppSpacing.sm, child: widget.badge!),
          if (count > 1)
            Positioned(
              bottom: AppSpacing.sm,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(count, (int i) {
                  final bool active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: AppRadii.pillAll,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

/// Simple month-by-month bar chart for the earnings breakdown endpoint.
class EarningsBars extends StatelessWidget {
  const EarningsBars({super.key, required this.entries});

  final List<MapEntry<String, double>> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (entries.isEmpty) return const SizedBox.shrink();
    final double peak = entries
        .map((MapEntry<String, double> e) => e.value)
        .reduce((double a, double b) => a > b ? a : b);
    final double maxValue = peak <= 0 ? 1 : peak;

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.takeLast(6).map((MapEntry<String, double> entry) {
          final double ratio = (entry.value / maxValue).clamp(0.04, 1.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    Money.compact(entry.value).replaceAll(' RWF', ''),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: ratio,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadii.sm),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.accent,
                              AppColors.accent.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _monthLabel(entry.key),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _monthLabel(String key) {
    final DateTime? parsed = Dates.tryIso('$key-01');
    return parsed == null ? key : Dates.monthShort(parsed);
  }
}
