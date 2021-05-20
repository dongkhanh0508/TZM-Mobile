import 'package:asset_app/model/asset.dart';
import 'package:asset_app/provider/asset_provider.dart';

class AssetRepository {
  AssetProvider _assetProvider = new AssetProvider();

  Future<Asset> authenticator(int brandId, int storeId, String assetId) async {
    return await _assetProvider.authenticator(brandId, storeId, assetId);
  }
}