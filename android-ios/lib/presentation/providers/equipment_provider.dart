import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/paginated_response.dart';
import '../../data/repositories/equipment_repository.dart';
import '../../data/services/api_client.dart';

// Repository Provider
final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepository(ref.watch(apiClientProvider));
});

// Equipment List State
class EquipmentListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<EquipmentModel> equipment;
  final int currentPage;
  final int totalPages;
  final String? errorMessage;
  final bool hasMore;

  EquipmentListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.equipment = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.errorMessage,
    this.hasMore = true,
  });

  EquipmentListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<EquipmentModel>? equipment,
    int? currentPage,
    int? totalPages,
    String? errorMessage,
    bool? hasMore,
  }) {
    return EquipmentListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      equipment: equipment ?? this.equipment,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Equipment List Notifier
class EquipmentListNotifier extends StateNotifier<EquipmentListState> {
  final EquipmentRepository _repository;

  EquipmentListNotifier(this._repository) : super(EquipmentListState());

  Future<void> loadEquipment({
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? date,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _repository.getEquipment(
        category: category,
        location: location,
        minPrice: minPrice,
        maxPrice: maxPrice,
        date: date,
        search: search,
        page: 1,
      );

      state = state.copyWith(
        isLoading: false,
        equipment: response.data,
        currentPage: response.meta.page,
        totalPages: response.meta.totalPages,
        hasMore: response.meta.page < response.meta.totalPages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final response = await _repository.getEquipment(
        page: state.currentPage + 1,
      );

      state = state.copyWith(
        isLoadingMore: false,
        equipment: [...state.equipment, ...response.data],
        currentPage: response.meta.page,
        totalPages: response.meta.totalPages,
        hasMore: response.meta.page < response.meta.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void refresh() {
    loadEquipment();
  }
}

// Equipment List Provider
final equipmentListProvider =
    StateNotifierProvider<EquipmentListNotifier, EquipmentListState>((ref) {
  return EquipmentListNotifier(ref.watch(equipmentRepositoryProvider));
});

// Single Equipment Provider
final equipmentProvider =
    FutureProvider.family<EquipmentModel, String>((ref, id) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getEquipmentById(id);
});

// My Equipment Provider
final myEquipmentProvider =
    StateNotifierProvider<EquipmentListNotifier, EquipmentListState>((ref) {
  return EquipmentListNotifier(ref.watch(equipmentRepositoryProvider));
});
