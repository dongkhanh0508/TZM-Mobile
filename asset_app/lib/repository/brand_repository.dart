import 'package:asset_app/model/brand.dart';
import 'package:asset_app/model/store.dart';
import 'package:asset_app/provider/brand_provider.dart';

class BrandRepository {
  BrandProvider _brandProvider = new BrandProvider();

  Future<List<Brand>> fetchListBrands() async {
    return await _brandProvider.fetchListBrands();
  }

  Future<List<Store>> fetchListBrandStores(int id) async {
    return await _brandProvider.fetchListBrandStores(id);
  }
}