import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AssetEvent extends Equatable {}

class LoadInitAsset extends AssetEvent {
  @override
  String toString() => 'LoadInitAsset';

  @override
  List<Object> get props => [];
}

class AuthenticateAsset extends AssetEvent {
  final int brandId;
  final int storeId;
  final String assetId;
  AuthenticateAsset({Key key, this.brandId, this.storeId, this.assetId});

  @override
  String toString() => 'AuthenticateAsset';

  @override
  List<Object> get props => [brandId, storeId, assetId];
}