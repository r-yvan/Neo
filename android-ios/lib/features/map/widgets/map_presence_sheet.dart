import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../data/models/map_models.dart';
import '../../../data/providers.dart';

/// Opens the "Show me on the map" settings. Resolves to the saved presence,
/// or null if nothing changed.
Future<MapPresence?> showMapPresenceSheet(
  BuildContext context, {
  MapPresence? initial,
}) =>
    showNeoSheet<MapPresence>(
      context,
      scrollable: true,
      child: _PresenceSheet(initial: initial ?? const MapPresence()),
    );

class _PresenceSheet extends ConsumerStatefulWidget {
  const _PresenceSheet({required this.initial});

  final MapPresence initial;

  @override
  ConsumerState<_PresenceSheet> createState() => _PresenceSheetState();
}

class _PresenceSheetState extends ConsumerState<_PresenceSheet> {
  late bool _visible = widget.initial.showOnMap;
  late final TextEditingController _note =
      TextEditingController(text: widget.initial.note ?? '');
  late final TextEditingController _area =
      TextEditingController(text: widget.initial.locationLabel ?? '');

  double? _lat;
  double? _lng;
  bool _locating = false;
  bool _saving = false;

  bool get _hasLocation => _lat != null || widget.initial.hasLocation;

  @override
  void dispose() {
    _note.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<bool> _locate() async {
    setState(() => _locating = true);
    final LocationFix fix = await LocationService.current();
    if (!mounted) return false;
    setState(() => _locating = false);
    if (!fix.ok) {
      final S s = L10n.i;
      showNeoSnack(
        context,
        fix.status == LocationStatus.serviceOff ? s.mapLocationOff : s.mapLocationDenied,
        isError: true,
      );
      return false;
    }
    setState(() {
      _lat = fix.latitude;
      _lng = fix.longitude;
    });
    return true;
  }

  Future<void> _save() async {
    if (_visible && !_hasLocation && !await _locate()) return;
    setState(() => _saving = true);
    try {
      final MapPresence saved = await ref.read(mapRepositoryProvider).updatePresence(
            latitude: _lat,
            longitude: _lng,
            locationLabel: _area.text.trim(),
            note: _note.text.trim(),
            showOnMap: _visible,
          );
      if (!mounted) return;
      showNeoSnack(context, L10n.i.mapMeSaved, icon: Icons.check_rounded);
      Navigator.of(context).pop(saved);
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _remove() async {
    final S s = L10n.i;
    final bool ok = await confirmNeo(context,
        title: s.mapMeRemove,
        message: s.mapMePrivacy,
        confirmLabel: s.commonRemove,
        destructive: true);
    if (!ok || !mounted) return;
    setState(() => _saving = true);
    try {
      final MapPresence cleared = await ref.read(mapRepositoryProvider).clearPresence();
      if (!mounted) return;
      showNeoSnack(context, s.mapMeRemoved, icon: Icons.delete_outline_rounded);
      Navigator.of(context).pop(cleared);
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = L10n.i;
    final ThemeData theme = Theme.of(context);
    final String locationText = _lat != null
        ? s.mapMeLocationSet
        : widget.initial.hasLocation
            ? '${s.mapMeLocationSet} · ${Dates.relative(widget.initial.updatedAt)}'
            : s.mapMeNoLocation;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: AppRadii.mdAll,
                ),
                child: const Icon(Icons.person_pin_circle_rounded, color: AppColors.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.mapMeTitle, style: theme.textTheme.titleLarge),
                    Text(s.mapMeSubtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          NeoCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _visible,
              activeTrackColor: AppColors.accent,
              onChanged: _saving ? null : (bool v) => setState(() => _visible = v),
              title: Text(s.mapMeSwitch, style: theme.textTheme.titleSmall),
              subtitle: Text(_visible ? s.mapMeVisible : s.mapMeHidden,
                  style: theme.textTheme.bodySmall),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentSofter,
              borderRadius: AppRadii.mdAll,
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.shield_outlined, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Expanded(child: Text(s.mapMePrivacy, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          NeoField(
            label: s.mapMeNote,
            hint: s.mapMeNoteHint,
            controller: _note,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.sm),
          NeoField(
            label: s.mapMeArea,
            hint: s.mapMeAreaHint,
            controller: _area,
            prefixIcon: Icons.place_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Icon(
                _hasLocation ? Icons.my_location_rounded : Icons.location_disabled_outlined,
                size: 18,
                color: _hasLocation ? AppColors.success : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(locationText, style: theme.textTheme.bodySmall)),
              TextButton.icon(
                onPressed: _locating || _saving ? null : _locate,
                icon: _locating
                    ? const SizedBox(
                        width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.gps_fixed_rounded, size: 16),
                label: Text(s.mapMeUseLocation),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          NeoButton(
            label: s.commonSave,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
          if (widget.initial.hasLocation) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: _saving ? null : _remove,
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: Text(s.mapMeRemove),
            ),
          ],
        ],
      ),
    );
  }
}
