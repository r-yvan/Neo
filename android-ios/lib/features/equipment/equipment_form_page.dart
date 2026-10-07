import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/equipment_repository.dart';
import '../auth/login_page.dart' show NeoErrorBanner;
import 'availability_page.dart';

/// Create or edit a listing.
///
/// Images are stored as strings in the API, so this screen supports both a
/// device pick (stored as an absolute file path and rendered locally) and a
/// direct URL entry for assets already hosted somewhere.
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
  final TextEditingController _imageUrl = TextEditingController();

  late EquipmentCategory _category =
      widget.existing?.category ?? EquipmentCategory.chairs;
  late List<String> _images =
      List<String>.from(widget.existing?.images ?? const <String>[]);
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
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (picked == null) return;
      setState(() => _images = <String>[..._images, picked.path]);
    } catch (e) {
      if (mounted)
        showNeoSnack(context, 'Could not open the gallery', isError: true);
    }
  }

  void _addImageUrl() {
    final String url = _imageUrl.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      showNeoSnack(context, 'Enter a full http(s) URL', isError: true);
      return;
    }
    setState(() {
      _images = <String>[..._images, url];
      _imageUrl.clear();
    });
  }

  Future<void> _removeImage(int index) async {
    final String source = _images[index];
    setState(() => _images = List<String>.from(_images)..removeAt(index));

    // Persist the removal when the listing already exists.
    if (widget.existing != null) {
      try {
        await ref
            .read(equipmentRepositoryProvider)
            .removeImage(widget.existing!.id, '$index');
      } catch (_) {
        // Local state is already correct; the next full save reconciles.
      }
    }
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
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final EquipmentRepository repo = ref.read(equipmentRepositoryProvider);
      Equipment saved;
      if (widget.existing == null) {
        saved = await repo.create(_draft());
        if (_images.isNotEmpty) {
          saved = await repo.addImages(saved.id, _images);
        }
      } else {
        saved = await repo.update(widget.existing!.id, _draft());
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
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Photos', style: theme.textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(
            'Listings with photos are booked far more often. Add up to six.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 84,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (int i = 0; i < _images.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: Stack(
                      children: [
                        EquipmentImage(
                          source: _images[i],
                          width: 84,
                          height: 84,
                          radius: AppRadii.md,
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _removeImage(i),
                              child: const Padding(
                                padding: EdgeInsets.all(3),
                                child: Icon(Icons.close_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_images.length < 6)
                  _addTile(() => _pickImage(ImageSource.gallery)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: NeoField(
                  label: 'Or paste an image URL',
                  controller: _imageUrl,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addImageUrl(),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: NeoIconButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Add URL',
                  filled: true,
                  onPressed: _addImageUrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          NeoButton(
            label: 'Take a photo',
            variant: NeoButtonVariant.ghost,
            icon: Icons.camera_alt_outlined,
            onPressed: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _addTile(VoidCallback onTap) {
    return Material(
      color: AppColors.accentSoft,
      borderRadius: AppRadii.mdAll,
      child: InkWell(
        borderRadius: AppRadii.mdAll,
        onTap: onTap,
        child: SizedBox(
          width: 84,
          height: 84,
          child:
              const Icon(Icons.add_a_photo_outlined, color: AppColors.accent),
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
