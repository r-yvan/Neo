import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/equipment_repository.dart';
import '../auth/login_page.dart' show NeoErrorBanner;
import '../common/photo_picker.dart';
import 'availability_page.dart';

/// Create or edit a listing.
///
/// Photos are uploaded to `POST /uploads` the moment they are picked; the
/// listing only ever stores the returned public URLs.
class EquipmentFormPage extends ConsumerStatefulWidget {
  const EquipmentFormPage({super.key, this.existing});

  final Equipment? existing;

  bool get isEdit => existing != null;

  @override
  ConsumerState<EquipmentFormPage> createState() => _EquipmentFormPageState();
}

class _EquipmentFormPageState extends ConsumerState<EquipmentFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _quantity =
      TextEditingController(text: '${widget.existing?.quantity ?? 20}');
  late final TextEditingController _price = TextEditingController(
      text: widget.existing == null
          ? ''
          : widget.existing!.pricePerDay.round().toString());
  late final TextEditingController _deposit = TextEditingController(
      text: widget.existing?.depositAmount == null
          ? ''
          : widget.existing!.depositAmount!.round().toString());
  late final TextEditingController _location =
      TextEditingController(text: widget.existing?.location ?? '');

  late EquipmentCategory _category =
      widget.existing?.category ?? EquipmentCategory.chairs;
  late final List<String> _originalImages =
      List<String>.from(widget.existing?.images ?? const <String>[]);
  late List<String> _images = List<String>.from(_originalImages);

  /// Upload progress (0–1) per in-flight photo, keyed by a local token.
  final Map<int, double> _uploads = <int, double>{};
  int _uploadSeq = 0;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _quantity.dispose();
    _price.dispose();
    _deposit.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final int token = _uploadSeq++;
    final String? url = await pickAndUploadPhoto(
      context,
      ref,
      onPicked: () => setState(() => _uploads[token] = 0),
      onProgress: (double v) {
        if (mounted) setState(() => _uploads[token] = v);
      },
    );
    if (!mounted) return;
    setState(() {
      _uploads.remove(token);
      if (url != null && url.isNotEmpty) _images = <String>[..._images, url];
    });
  }

  void _removeImage(int index) {
    setState(() => _images = List<String>.from(_images)..removeAt(index));
  }

  void _makeCover(int index) {
    if (index == 0) return;
    setState(() {
      final List<String> next = List<String>.from(_images);
      final String picked = next.removeAt(index);
      _images = <String>[picked, ...next];
    });
  }

  /// Applies photo changes to an existing listing (the update DTO does not
  /// carry images, so additions/removals use the dedicated endpoints).
  Future<Equipment> _syncImages(EquipmentRepository repo, Equipment saved) async {
    Equipment current = saved;
    final bool reordered = _images.isNotEmpty &&
        _originalImages.isNotEmpty &&
        _images.first != _originalImages.first;
    final List<String> toRemove = reordered
        ? _originalImages
        : _originalImages.where((String u) => !_images.contains(u)).toList();
    final List<String> toAdd = reordered
        ? _images
        : _images.where((String u) => !_originalImages.contains(u)).toList();
    for (final String url in toRemove) {
      current = await repo.removeImage(saved.id, url);
    }
    if (toAdd.isNotEmpty) current = await repo.addImages(saved.id, toAdd);
    return current;
  }

  EquipmentDraft _draft() => EquipmentDraft(
        title: _title.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        category: _category,
        quantity: int.parse(_quantity.text.trim()),
        pricePerDay: double.parse(_price.text.trim().replaceAll(',', '')),
        depositAmount: _deposit.text.trim().isEmpty
            ? null
            : double.parse(_deposit.text.trim().replaceAll(',', '')),
        location: _location.text.trim(),
        images: _images,
      );

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_uploads.isNotEmpty) {
      showNeoSnack(context, L10n.i.formPhotosWaitUpload, isError: true);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final EquipmentRepository repo = ref.read(equipmentRepositoryProvider);
      Equipment saved;
      if (widget.existing == null) {
        // Images travel in the create body — no second call needed.
        saved = await repo.create(_draft());
      } else {
        saved = await repo.update(widget.existing!.id, _draft());
        saved = await _syncImages(repo, saved);
      }
      if (!mounted) return;
      Navigator.of(context).pop(saved);
      showNeoSnack(
        context,
        widget.isEdit ? 'Listing updated' : 'Listing published',
        icon: Icons.check_circle_outline_rounded,
      );
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppUser? user = ref.watch(sessionProvider).user;
    final bool canList = user?.isOwner ?? false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          widget.isEdit ? 'Edit listing' : 'New listing',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              if (!canList) ...[
                NeoCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 18, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Owner role required',
                                style: theme.textTheme.titleSmall),
                            const SizedBox(height: 2),
                            Text(
                              'Switch to the owner role on the My gear tab before publishing a listing.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              _photos(theme),
              const SizedBox(height: AppSpacing.lg),
              NeoField(
                label: 'Title',
                hint: 'White plastic chairs (50 pcs)',
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: Validators.title,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Category', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: EquipmentCategory.values.map((EquipmentCategory c) {
                  return NeoChip(
                    label: c.label,
                    dense: true,
                    selected: _category == c,
                    onTap: () => setState(() => _category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: NeoField(
                      label: 'Price per day (RWF)',
                      hint: '1500',
                      controller: _price,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: Validators.price,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: NeoField(
                      label: 'Units you own',
                      hint: '50',
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: Validators.quantity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              NeoField(
                label: 'Security deposit per booking (optional)',
                hint: '0',
                controller: _deposit,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              NeoField(
                label: 'Collection area',
                hint: 'Kigali - Nyarugenge',
                controller: _location,
                prefixIcon: Icons.place_outlined,
                textInputAction: TextInputAction.next,
                validator: Validators.location,
              ),
              const SizedBox(height: AppSpacing.sm),
              _locationSuggestions(context),
              const SizedBox(height: AppSpacing.md),
              NeoField(
                label: 'Description',
                hint: 'Condition, delivery options, what is included…',
                controller: _description,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.description,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                NeoErrorBanner(message: _error!),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (widget.existing != null) ...[
                NeoButton(
                  label: 'Manage availability calendar',
                  variant: NeoButtonVariant.secondary,
                  icon: Icons.event_note_rounded,
                  onPressed: () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (BuildContext _) =>
                            AvailabilityPage(equipment: widget.existing!),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              NeoButton(
                label: widget.isEdit ? 'Save changes' : 'Publish listing',
                loading: _busy,
                icon: widget.isEdit
                    ? Icons.check_rounded
                    : Icons.rocket_launch_rounded,
                onPressed: _busy || !canList ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photos(ThemeData theme) {
    final S s = L10n.i;
    const double tile = 96;
    final bool canAdd = _images.length + _uploads.length < 6;
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.formPhotosTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(s.formPhotosHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: tile,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (int i = 0; i < _images.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: GestureDetector(
                      onLongPress: () => _makeCover(i),
                      child: Stack(
                        children: [
                          EquipmentImage(
                            source: _images[i],
                            width: tile,
                            height: tile,
                            radius: AppRadii.md,
                          ),
                          if (i == 0)
                            Positioned(
                              left: 6,
                              bottom: 6,
                              child: NeoBadge(
                                  label: s.photoCover, tone: BadgeTone.accent),
                            ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Material(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _removeImage(i),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.close_rounded,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                for (final double progress in _uploads.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: _UploadingTile(size: tile, progress: progress),
                  ),
                if (canAdd) _addTile(tile, _busy ? null : _addPhoto),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addTile(double size, VoidCallback? onTap) {
    return Material(
      color: AppColors.accentSofter,
      borderRadius: AppRadii.mdAll,
      child: InkWell(
        borderRadius: AppRadii.mdAll,
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: AppRadii.mdAll,
            border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.35), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_outlined, color: AppColors.accent),
              const SizedBox(height: 6),
              Text(
                L10n.i.photoChooseSource,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationSuggestions(BuildContext context) {
    final AsyncValue<List<RwandaLocation>> locations =
        ref.watch(locationsProvider);
    return locations.maybeWhen(
      data: (List<RwandaLocation> data) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: data
            .take(2)
            .expand((RwandaLocation l) => l.districts.take(4))
            .map((String district) => NeoChip(
                  label: district,
                  dense: true,
                  selected: _location.text == district,
                  onTap: () =>
                      setState(() => _location.text = 'Kigali - $district'),
                ))
            .toList(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// Convenience for callers that just need "today" in the local timezone.
DateTime today() => Dates.dayOnly(DateTime.now());

class _UploadingTile extends StatelessWidget {
  const _UploadingTile({required this.size, required this.progress});

  final double size;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.mdAll,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              value: progress <= 0 || progress >= 1 ? null : progress,
              strokeWidth: 2.6,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(L10n.i.photoUploading, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
