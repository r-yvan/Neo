import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/providers.dart';

/// Asks where the photo should come from. Returns null when dismissed.
Future<ImageSource?> askPhotoSource(BuildContext context) {
  final S s = L10n.i;
  final ThemeData theme = Theme.of(context);
  Widget option(BuildContext ctx, IconData icon, String label, ImageSource v) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: AppRadii.mdAll,
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(label, style: theme.textTheme.titleSmall),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.of(ctx).pop(v),
      );

  return showNeoSheet<ImageSource>(
    context,
    child: Builder(
      builder: (BuildContext ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.photoChooseSource, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          option(ctx, Icons.photo_camera_outlined, s.photoTakeNew,
              ImageSource.camera),
          option(ctx, Icons.photo_library_outlined, s.photoFromGallery,
              ImageSource.gallery),
        ],
      ),
    ),
  );
}

/// Picks one image (asking for the source unless given) and uploads it.
///
/// Returns the public URL, or null if the user cancelled. Upload failures are
/// surfaced as a snackbar and also return null.
Future<String?> pickAndUploadPhoto(
  BuildContext context,
  WidgetRef ref, {
  ImageSource? source,
  ValueChanged<double>? onProgress,
  VoidCallback? onPicked,
  double maxWidth = 1600,
}) async {
  final ImageSource? from = source ?? await askPhotoSource(context);
  if (from == null) return null;

  final XFile? file;
  try {
    file = await ImagePicker().pickImage(
      source: from,
      imageQuality: 82,
      maxWidth: maxWidth,
    );
  } catch (_) {
    if (context.mounted) {
      showNeoSnack(context, L10n.i.photoUploadFailed, isError: true);
    }
    return null;
  }
  if (file == null) return null;
  onPicked?.call();

  try {
    return await ref
        .read(mediaRepositoryProvider)
        .uploadImage(file, onProgress: onProgress);
  } on ApiException catch (e) {
    if (context.mounted) showNeoSnack(context, e.message, isError: true);
  } catch (_) {
    if (context.mounted) {
      showNeoSnack(context, L10n.i.photoUploadFailed, isError: true);
    }
  }
  return null;
}
