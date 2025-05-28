// lib/bloc/trending/trending_event.dart
import 'package:equatable/equatable.dart';

abstract class TrendingEvent extends Equatable {
  const TrendingEvent();

  @override
  List<Object> get props => [];
}

class FetchTrendingProducts extends TrendingEvent {
  final String sortBy; // 'views' atau 'purchases'

  const FetchTrendingProducts(this.sortBy);

  @override
  List<Object> get props => [sortBy];
}
