import 'package:equatable/equatable.dart';
import 'package:cuan_space/models/product.dart';

abstract class TrendingState extends Equatable {
  const TrendingState();

  @override
  List<Object> get props => [];
}

class TrendingInitial extends TrendingState {}

class TrendingLoading extends TrendingState {}

class TrendingLoaded extends TrendingState {
  final List<Product> products;

  const TrendingLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class TrendingError extends TrendingState {
  final String message;

  const TrendingError(this.message);

  @override
  List<Object> get props => [message];
}

class TrendingNavigateToLogin extends TrendingState {}