import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';

/// Creates a review for a completed booking.
///
/// The backend enforces the rules: only the renter can review, only once the
/// booking is COMPLETED, and only one review per booking.
Future<bool?> showWriteReviewSheet(BuildContext context, Booking booking) {
  return showNeoSheet<bool>(
    context,
    child: _WriteReviewForm(booking: booking),
  );
}

class _WriteReviewForm extends ConsumerStatefulWidget {
  const _WriteReviewForm({required this.booking});

  final Booking booking;

  @override
  ConsumerState<_WriteReviewForm> createState() => _WriteReviewFormState();
}

class _WriteReviewFormState extends ConsumerState<_WriteReviewForm> {
  final TextEditingController _comment = TextEditingController();
  int _rating = 0;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      showNeoSnack(context, 'Choose a star rating', isError: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(reviewsRepositoryProvider).create(
            bookingId: widget.booking.id,
            rating: _rating,
            comment: _comment.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showNeoSnack(context, 'Thanks for the review',
          icon: Icons.star_rounded);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showNeoSnack(context, e.message, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Equipment? item = widget.booking.equipment;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('How was the rental?',
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(
            item == null
                ? 'Your review helps other people rent with confidence.'
                : 'Your review of ${item.title} helps other people rent with confidence.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: RatingBar.builder(
              initialRating: _rating.toDouble(),
              itemCount: 5,
              itemSize: 38,
              unratedColor: AppColors.grey200,
              itemBuilder: (BuildContext context, int _) =>
                  const Icon(Icons.star_rounded, color: AppColors.star),
              onRatingUpdate: (double value) =>
                  setState(() => _rating = value.round()),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              _label,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          NeoField(
            label: 'Comment (optional)',
            hint: 'Condition on arrival, pickup experience…',
            controller: _comment,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.lg),
          NeoButton(
            label: 'Submit review',
            loading: _busy,
            onPressed: _busy ? null : _submit,
          ),
        ],
      ),
    );
  }

  String get _label => switch (_rating) {
        1 => 'Poor',
        2 => 'Below expectations',
        3 => 'Fine',
        4 => 'Good',
        5 => 'Excellent',
        _ => 'Tap to rate',
      };
}