import 'dart:convert';
import 'dart:io';
import 'package:asset_app/base_url.dart';
import 'package:asset_app/model/brand.dart';
import 'package:asset_app/model/store.dart';
import 'package:http/http.dart' as http;

class BrandProvider {
  Future<List<Brand>> fetchListBrands() async {
    final http.Response response = await http.get(
      BaseUrl.brands,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if (response.statusCode == 200) {
      List<Brand> rs = new List<Brand>();
      dynamic results = jsonDecode(response.body);
      results.forEach((brand) { 
        rs.add(new Brand.fromJson(brand));
      });
      return rs;
    } else if (response.statusCode == 204) {
      List<Brand> rs = new List<Brand>();
      return rs;
    } else {
      return null;
    }
  }

  Future<List<Store>> fetchListBrandStores(int id) async {
    final http.Response response = await http.get(
      BaseUrl.listbrandstores(id),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if (response.statusCode == 200) {
      List<Store> rs = new List<Store>();
      dynamic results = jsonDecode(response.body);
      results.forEach((store) { 
        rs.add(new Store.fromJson(store));
      });
      return rs;
    } else if (response.statusCode == 204) {
      List<Store> rs = new List<Store>();
      return rs;
    } else {
      return null;
    }
  }
}