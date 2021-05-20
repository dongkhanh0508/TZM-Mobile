import 'dart:async';
import 'package:asset_app/event/asset_event.dart';
import 'package:asset_app/model/asset.dart';
import 'package:asset_app/repository/asset_repository.dart';
import 'package:asset_app/state/asset_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  AssetRepository _assetRepository = AssetRepository();
  AssetBloc({@required AssetRepository assetRepository}) : assert(AssetRepository != null),
    _assetRepository = assetRepository;

  // load authenticat controller
  final _authenticatorController = StreamController<Asset>();
  StreamSink<Asset> get authenticatorSink => _authenticatorController.sink;
  Stream<Asset> get authenticatorStream => _authenticatorController.stream;

  Stream<AssetState> authenticator(int brandId, int storeId, String assetId) async* {
    final rs = await _assetRepository.authenticator(brandId, storeId, assetId);
    authenticatorSink.add(rs);
    yield LoadAuthenticatorAssetState();
    yield LoadAuthenticatorAssetFinishState(asset: rs);
  }

  @override
  AssetState get initialState => LoadAssetsInitState();

  @override
  Future<void> close() {
    _authenticatorController.close();
    return super.close();
  }

  @override
  Stream<AssetState> mapEventToState(AssetEvent event) async* {
    if (event is AuthenticateAsset) {
      yield* authenticator(event.brandId, event.storeId, event.assetId);
    }
  }
}
