import 'dart:io';
import 'package:asset_app/base_url.dart';
import 'package:asset_app/model/asset.dart';
import 'package:geodesy/geodesy.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

Asset currentAsset;

class AssetProvider {
  Future<Asset> authenticator(int brandId, int storeId, String assetId) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = '{' + 
      '"brandId": ' + brandId.toString() + ',' +
      '"storeId": ' + storeId.toString() + ',' + 
      '"assetId": "' + assetId.toString() + '"' +
      '}';
    final http.Response response = await http.post(
      BaseUrl.authenticateassets,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonString
    );
    if (response.statusCode == 200) {
      prefs.setString('jwt', response.body);
      Asset rs = new Asset.fromJson(JwtDecoder.decode(response.body));
      return rs;
    } else {
      return null;
    }
  }

  Future<bool> postLocation(LatLng location) async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString('jwt');
    String jsonString = '{"location": "' + location.longitude.toString() + ' ' + location.latitude.toString() + '"' + '}';
    final http.Response response = await http.post(
      BaseUrl.assetlocation,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwtToken
      },
      body: jsonString,
    );
    if (response.statusCode == 200) {
      print("true");
      return true;
    } else {
      print("false");
      return false;
    }
  }
}