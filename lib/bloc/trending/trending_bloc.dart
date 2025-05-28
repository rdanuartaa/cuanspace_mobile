import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../models/product.dart'; // TAMBAHKAN INI
import 'trending_event.dart';
import 'trending_state.dart';

class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  final ApiService apiService;

  TrendingBloc(this.apiService) : super(TrendingInitial()) {
    on<FetchTrendingProducts>((event, emit) async {
      emit(TrendingLoading());
      try {
        final response = await apiService.fetchTrendingProducts(event.sortBy);
        if (response['success']) {
          final products = (response['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
          emit(TrendingLoaded(products));
        } else {
          emit(TrendingError(response['message']));
        }
      } catch (e) {
        emit(TrendingError('Gagal memuat data: $e'));
      }
    });
  }
}
