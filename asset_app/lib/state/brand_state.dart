import 'package:asset_app/model/brand.dart';
import 'package:asset_app/model/store.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class BrandState extends Equatable {}

class LoadBrandsState extends BrandState {
  @override
  List<Object> get props => [];
}

class LoadBrandsFinishState extends BrandState {
  final List<Brand> listBrands;
  LoadBrandsFinishState({Key key, @required this.listBrands});

  @override
  List<Object> get props => [listBrands];
}

class LoadInitState extends BrandState {
  @override
  List<Object> get props => [];
}

class LoadBrandStoresState extends BrandState {
  @override
  List<Object> get props => [];
}

class LoadBrandStoresFinishState extends BrandState {
  final List<Store> listStores;
  LoadBrandStoresFinishState({Key key, this.listStores});

  @override
  List<Object> get props => [listStores];
}
