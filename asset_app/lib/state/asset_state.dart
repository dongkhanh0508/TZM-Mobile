import 'package:asset_app/model/asset.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class AssetState extends Equatable {}

class LoadAssetsInitState extends AssetState {
  @override
  List<Object> get props => [];
}

class LoadAuthenticatorAssetState extends AssetState {
  @override
  List<Object> get props => [];
}

class LoadAuthenticatorAssetFinishState extends AssetState {
  final Asset asset;
  LoadAuthenticatorAssetFinishState({Key key, this.asset});

  @override
  List<Object> get props => [asset];
}
