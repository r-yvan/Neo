import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/location/location_service.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/map_models.dart';
import '../../data/providers.dart';
import '../chat/chat_page.dart';
import '../profile/public_profile_page.dart';
import 'widgets/map_person_card.dart';
import 'widgets/map_pins.dart';
import 'widgets/map_presence_sheet.dart';

/// Map of nearby lenders (owners with live listings) and borrowers (renters
/// who chose to be visible). Pins and the bottom carousel stay in sync.
class NearbyMapPage extends ConsumerStatefulWidget {
  const NearbyMapPage({super.key, this.initialLayer = MapLayer.all});

  final MapLayer initialLayer;

  @override
  ConsumerState<NearbyMapPage> createState() => _NearbyMapPageState();
}

class _NearbyMapPageState extends ConsumerState<NearbyMapPage>
    with TickerProviderStateMixin {
  static const LatLng _kigali =
      LatLng(AppConfig.defaultLatitude, AppConfig.defaultLongitude);
  static const List<int> _radii = <int>[5, 10, 15, 25, 50];
  static const double _carouselHeight = 178;

  final MapController _map = MapController();
  final PageController _pages = PageController(viewportFraction: 0.88);
  AnimationController? _flight;

  late MapLayer _layer = widget.initialLayer;
  LatLng _queryCenter = _kigali;
  LatLng? _me;
  int _radiusKm = 10;
  MapNearby? _data;
  MapPresence? _presence;
  bool _loading = true;
  bool _mapReady = false;
  bool _showSearchArea = false;
  String? _error;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _flight?.dispose();
    _pages.dispose();
    _map.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ data

  Future<void> _bootstrap() async {
    _loadPresence();
    final LocationFix fix = await LocationService.current();
    if (!mounted) return;
    if (fix.ok) {
      _me = LatLng(fix.latitude!, fix.longitude!);
      _queryCenter = _me!;
    } else {
      showNeoSnack(context, L10n.i.mapUsingDefault, icon: Icons.location_off_outlined);
    }
    await _load(fit: true);
  }

  Future<void> _loadPresence() async {
    try {
      final MapPresence p = await ref.read(mapRepositoryProvider).presence();
      if (mounted) setState(() => _presence = p);
    } catch (_) {}
  }

  Future<void> _load({bool fit = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      _showSearchArea = false;
    });
    try {
      final MapNearby data = await ref.read(mapRepositoryProvider).nearby(
            latitude: _queryCenter.latitude,
            longitude: _queryCenter.longitude,
            radiusKm: _radiusKm.toDouble(),
          );
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
        if (!_items.any((MapPerson p) => p.key == _selectedId)) _selectedId = null;
      });
      if (_pages.hasClients) _pages.jumpToPage(0);
      if (fit) _fitRadius();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  /// Visible people for the active layer, nearest first.
  List<MapPerson> get _items {
    final MapNearby? d = _data;
    if (d == null) return const <MapPerson>[];
    final List<MapPerson> out = <MapPerson>[
      if (_layer != MapLayer.borrowers) ...d.lenders,
      if (_layer != MapLayer.lenders) ...d.borrowers,
    ]..sort((MapPerson a, MapPerson b) => a.distanceKm.compareTo(b.distanceKm));
    return out;
  }

  // ---------------------------------------------------------------- camera

  void _fitRadius() {
    if (!_mapReady) return;
    final double dLat = _radiusKm / 111.32;
    final double dLng =
        _radiusKm / (111.32 * math.cos(_queryCenter.latitude * math.pi / 180));
    final CameraFit fit = CameraFit.bounds(
      bounds: LatLngBounds(
        LatLng(_queryCenter.latitude - dLat, _queryCenter.longitude - dLng),
        LatLng(_queryCenter.latitude + dLat, _queryCenter.longitude + dLng),
      ),
      padding: const EdgeInsets.fromLTRB(24, 140, 24, _carouselHeight + 40),
    );
    final MapCamera target = fit.fit(_map.camera);
    _flyTo(target.center, target.zoom);
  }

  /// Smoothly animates the camera (flutter_map has no built-in flight).
  void _flyTo(LatLng dest, [double? zoom]) {
    if (!_mapReady) return;
    final MapCamera from = _map.camera;
    final double toZoom = zoom ?? from.zoom;
    _flight?.dispose();
    final AnimationController c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    final Animation<double> t = CurvedAnimation(parent: c, curve: Curves.easeInOutCubic);
    c.addListener(() {
      final double v = t.value;
      _map.move(
        LatLng(
          from.center.latitude + (dest.latitude - from.center.latitude) * v,
          from.center.longitude + (dest.longitude - from.center.longitude) * v,
        ),
        from.zoom + (toZoom - from.zoom) * v,
      );
    });
    _flight = c..forward();
  }

  void _onCameraMoved(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    final double km = const Distance()
            .as(LengthUnit.Meter, camera.center, _queryCenter) /
        1000;
    final bool far = km > _radiusKm * 0.35;
    if (far != _showSearchArea) setState(() => _showSearchArea = far);
  }

  // ------------------------------------------------------------- selection

  void _select(MapPerson p, {bool fromCarousel = false}) {
    setState(() => _selectedId = p.key);
    _flyTo(LatLng(p.latitude, p.longitude), math.max(_map.camera.zoom, 13.5));
    if (!fromCarousel) {
      final int index = _items.indexWhere((MapPerson x) => x.key == p.key);
      if (index >= 0 && _pages.hasClients) {
        _pages.animateToPage(index,
            duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
      }
    }
  }

  // --------------------------------------------------------------- actions

  Future<void> _recenter() async {
    final LocationFix fix = await LocationService.current();
    if (!mounted) return;
    if (!fix.ok) {
      final S s = L10n.i;
      final bool settings = fix.status == LocationStatus.deniedForever;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(fix.status == LocationStatus.serviceOff
              ? s.mapLocationOff
              : s.mapLocationDenied),
          action: settings
              ? SnackBarAction(label: s.mapOpenSettings, onPressed: LocationService.openSettings)
              : null,
        ));
      return;
    }
    setState(() {
      _me = LatLng(fix.latitude!, fix.longitude!);
      _queryCenter = _me!;
    });
    await _load(fit: true);
  }

  Future<void> _openPresence() async {
    final MapPresence? saved = await showMapPresenceSheet(context, initial: _presence);
    if (saved != null && mounted) setState(() => _presence = saved);
  }

  Future<void> _pickRadius() async {
    final S s = L10n.i;
    final int? picked = await showNeoSheet<int>(
      context,
      child: Builder(
        builder: (BuildContext ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.mapRadius, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final int r in _radii)
                  NeoChip(
                    label: s.mapRadiusKm(r),
                    selected: r == _radiusKm,
                    onTap: () => Navigator.of(ctx).pop(r),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (picked == null || picked == _radiusKm || !mounted) return;
    setState(() => _radiusKm = picked);
    await _load(fit: true);
  }

  void _openProfile(MapPerson p) => Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => PublicProfilePage(userId: p.id)));

  void _message(MapPerson p) => Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => ChatPage(peer: p.toUserRef())));

  // ------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final List<MapPerson> items = _items;
    final LatLng? myPin = _me ??
        (_presence?.hasLocation ?? false
            ? LatLng(_presence!.latitude!, _presence!.longitude!)
            : null);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _queryCenter,
              initialZoom: 12,
              minZoom: 4,
              maxZoom: 18,
              backgroundColor: dark ? AppColors.darkBackground : AppColors.grey150,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onMapReady: () {
                _mapReady = true;
                if (_data != null) _fitRadius();
              },
              onTap: (TapPosition _, LatLng __) => setState(() => _selectedId = null),
              onPositionChanged: _onCameraMoved,
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate: dark && AppConfig.mapTilesDark.isNotEmpty
                    ? AppConfig.mapTilesDark
                    : AppConfig.mapTilesLight,
                userAgentPackageName: 'rw.neo.neo_equipment',
                maxNativeZoom: 19,
                tileBuilder: AppConfig.mapTilesRecolour
                    ? (dark ? _darkTiles : _greyTiles)
                    : (dark && AppConfig.mapTilesDark.isEmpty ? _darkTiles : null),
              ),
              CircleLayer(
                circles: <CircleMarker>[
                  CircleMarker(
                    point: _queryCenter,
                    radius: _radiusKm * 1000,
                    useRadiusInMeter: true,
                    color: AppColors.accent.withValues(alpha: 0.05),
                    borderColor: AppColors.accent.withValues(alpha: 0.35),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: <Marker>[
                  // Unselected first so the selected pin is drawn on top.
                  for (final MapPerson p in items.where((MapPerson p) => p.key != _selectedId))
                    _marker(p, false),
                  for (final MapPerson p in items.where((MapPerson p) => p.key == _selectedId))
                    _marker(p, true),
                  if (myPin != null)
                    Marker(
                      point: myPin,
                      width: 56,
                      height: 56,
                      child: const MeMarker(),
                    ),
                ],
              ),
            ],
          ),

          // ---------------------------------------------------- top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _RoundButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: L10n.i.commonBack,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LayerSwitch(
                          value: _layer,
                          // People, not pins: a lender may have several areas.
                          lenders: _data?.lenders.map((MapLender l) => l.id).toSet().length,
                          borrowers: _data?.borrowers.length,
                          onChanged: (MapLayer l) => setState(() {
                            _layer = l;
                            _selectedId = null;
                            if (_pages.hasClients) _pages.jumpToPage(0);
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _RoundButton(
                        label: L10n.i.mapRadiusKm(_radiusKm),
                        tooltip: L10n.i.mapRadius,
                        onTap: _pickRadius,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _loading
                        ? _StatusPill(
                            key: const ValueKey<String>('loading'),
                            label: L10n.i.mapLoading,
                            busy: true,
                          )
                        : _showSearchArea
                            ? _StatusPill(
                                key: const ValueKey<String>('search'),
                                label: L10n.i.mapSearchArea,
                                icon: Icons.refresh_rounded,
                                accent: true,
                                onTap: () {
                                  _queryCenter = _map.camera.center;
                                  _load();
                                },
                              )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------ floating buttons
          Positioned(
            right: 16,
            bottom: _carouselHeight + 44,
            child: Column(
              children: <Widget>[
                _RoundButton(
                  icon: Icons.person_pin_circle_outlined,
                  tooltip: L10n.i.mapMeTitle,
                  active: _presence?.showOnMap ?? false,
                  onTap: _openPresence,
                ),
                const SizedBox(height: 10),
                _RoundButton(
                  icon: Icons.my_location_rounded,
                  tooltip: L10n.i.mapRecenter,
                  onTap: _recenter,
                ),
              ],
            ),
          ),

          // -------------------------------------- attribution + carousel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 6),
                    child: GestureDetector(
                      onTap: () => launchUrl(
                        Uri.parse('https://www.openstreetmap.org/copyright'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.85),
                          borderRadius: AppRadii.pillAll,
                        ),
                        child: Text(AppConfig.mapAttribution,
                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _carouselHeight,
                    child: _bottom(items),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _marker(MapPerson p, bool selected) => Marker(
        point: LatLng(p.latitude, p.longitude),
        width: kPinWidth,
        height: kPinHeight,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _select(p),
          child: MapPin(
            lender: p is MapLender,
            selected: selected,
            count: p is MapLender ? p.listingCount : 0,
          ),
        ),
      );

  Widget _bottom(List<MapPerson> items) {
    final S s = L10n.i;
    if (_error != null) {
      return _FloatingCard(child: NeoErrorState(message: _error!, onRetry: _load));
    }
    if (_data == null) return const SizedBox.shrink();
    if (items.isEmpty) {
      return _FloatingCard(
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: AppRadii.mdAll,
              ),
              child: const Icon(Icons.travel_explore_rounded, color: AppColors.accent),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(s.mapEmptyTitle, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(s.mapEmptyBody, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            TextButton(onPressed: _pickRadius, child: Text(s.mapRadius)),
          ],
        ),
      );
    }
    return PageView.builder(
      controller: _pages,
      itemCount: items.length,
      onPageChanged: (int i) => _select(items[i], fromCarousel: true),
      itemBuilder: (BuildContext context, int i) {
        final MapPerson p = items[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: MapPersonCard(
            person: p,
            selected: p.key == _selectedId,
            onTap: () => _select(p, fromCarousel: true),
            onProfile: () => _openProfile(p),
            onMessage: () => _message(p),
          ),
        );
      },
    );
  }
}

// --------------------------------------------------------------- chrome

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.onTap,
    required this.tooltip,
    this.icon,
    this.label,
    this.active = false,
  });

  final VoidCallback onTap;
  final String tooltip;
  final IconData? icon;
  final String? label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? AppColors.accent : theme.colorScheme.surface,
        shape: const StadiumBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 46,
            constraints: const BoxConstraints(minWidth: 46),
            padding: EdgeInsets.symmetric(horizontal: label == null ? 0 : 14),
            decoration: BoxDecoration(
              borderRadius: AppRadii.pillAll,
              boxShadow: AppShadows.raised,
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.6)),
            ),
            alignment: Alignment.center,
            child: label != null
                ? Text(label!, style: theme.textTheme.labelLarge)
                : Icon(icon, size: 21, color: active ? Colors.white : theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _LayerSwitch extends StatelessWidget {
  const _LayerSwitch({
    required this.value,
    required this.onChanged,
    this.lenders,
    this.borrowers,
  });

  final MapLayer value;
  final ValueChanged<MapLayer> onChanged;
  final int? lenders;
  final int? borrowers;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final S s = L10n.i;
    String withCount(String label, int? n) => n == null ? label : '$label $n';
    final List<(MapLayer, String)> options = <(MapLayer, String)>[
      (MapLayer.all, s.mapLayerAll),
      (MapLayer.lenders, withCount(s.mapLayerLenders, lenders)),
      (MapLayer.borrowers, withCount(s.mapLayerBorrowers, borrowers)),
    ];
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.pillAll,
        boxShadow: AppShadows.raised,
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: <Widget>[
          for (final (MapLayer layer, String label) in options)
            Expanded(
              flex: layer == MapLayer.all ? 2 : 3,
              child: GestureDetector(
                onTap: () => onChanged(layer),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: layer == value ? AppColors.accent : Colors.transparent,
                    borderRadius: AppRadii.pillAll,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: layer == value ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    super.key,
    required this.label,
    this.icon,
    this.busy = false,
    this.accent = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool busy;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fg = accent ? Colors.white : theme.colorScheme.onSurface;
    return Material(
      color: accent ? AppColors.accent : theme.colorScheme.surface,
      shape: const StadiumBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (busy)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                )
              else if (icon != null)
                Icon(icon, size: 16, color: fg),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.labelLarge?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadii.xlAll,
            boxShadow: AppShadows.raised,
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ tile styling

/// Desaturates tiles into the brand's neutral greys, slightly lifted so pins
/// and the accent radius stay the most saturated things on screen.
Widget _greyTiles(BuildContext context, Widget tile, TileImage _) =>
    ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.20, 0.64, 0.07, 0, 14, //
        0.20, 0.64, 0.07, 0, 14, //
        0.20, 0.64, 0.07, 0, 14, //
        0, 0, 0, 1, 0,
      ]),
      child: tile,
    );

/// Greyscale + inverted for dark mode, tuned to sit near the dark surface.
Widget _darkTiles(BuildContext context, Widget tile, TileImage _) =>
    ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.19, -0.62, -0.07, 0, 232, //
        -0.19, -0.62, -0.07, 0, 232, //
        -0.19, -0.62, -0.07, 0, 232, //
        0, 0, 0, 1, 0,
      ]),
      child: tile,
    );
