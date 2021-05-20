import 'dart:async';
import 'dart:convert';
import 'package:asset_app/bloc/asset_bloc.dart';
import 'package:asset_app/bloc/brand_bloc.dart';
import 'package:asset_app/config_base.dart';
import 'package:asset_app/event/asset_event.dart';
import 'package:asset_app/event/brand_event.dart';
import 'package:asset_app/model/asset.dart';
import 'package:asset_app/model/brand.dart';
import 'package:asset_app/model/store.dart';
import 'package:asset_app/provider/asset_provider.dart';
import 'package:asset_app/repository/asset_repository.dart';
import 'package:asset_app/repository/brand_repository.dart';
import 'package:asset_app/state/asset_state.dart';
import 'package:asset_app/state/brand_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geodesy/geodesy.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  BrandBloc _brandBloc;
  AssetBloc _assetBloc;
  List<Brand> _listBrand; 
  List<String> _listBrandName;
  String _brandValue;
  List<Store> _listStore;
  List<String> _listStoreName;
  TextEditingController _assetCodeController;
  String _storeValue;
  bool _isLoadBrand;
  bool _isLoadStore;
  bool _isLogin;
  bool _isLoginFail;
  bool _isPosting;
  Timer _timerPostingLocation;
  AssetProvider _assetProvider = AssetProvider();

  @override
  void initState() { 
    super.initState();
    _listBrand = new List<Brand>();
    _listBrandName = new List<String>();
    _listStore = new List<Store>();
    _listStoreName = new List<String>();
    _isLoadBrand = false;
    _isLoadStore = false;
    _isLogin = false;
    _isLoginFail = false;
    _isPosting = false;
    _assetCodeController = new TextEditingController();
    _brandBloc = BrandBloc(brandRepository: BrandRepository());
    _assetBloc = AssetBloc(assetRepository: AssetRepository());
    _initFunction();
  }

  void _initFunction() async {
    final prefs = await SharedPreferences.getInstance();
    String currentAssetStr = prefs.getString(Config.currentAssetSave);
    if (currentAssetStr != null) {
      setState(() {
        currentAsset = Asset.fromJsonSave(jsonDecode(currentAssetStr));
        _isLoadBrand = true;
        _isLoadStore = true;
      });
    } else {
      prefs.remove(Config.currentAssetSave);
      _brandBloc.add(LoadBrands());
    }
  }

  @override
  void dispose() { 
    _brandBloc.close();
    _assetBloc.close();
    _timerPostingLocation.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Config.secondColor,
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                blocListenerWidget(),
                Expanded(
                  child: Stack(
                    children: [
                      _headerWidget(context),
                      _assetWidget(context),
                      if (currentAsset != null) _postWidget(context),
                    ],
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  Widget blocListenerWidget() {
    return MultiBlocListener(
      listeners: [
        brandBlocListener(),
        assetBlocListener(),
      ], 
      child: SizedBox()
    );
  }

  Widget brandBlocListener() {
    return BlocListener(
      bloc: _brandBloc,
      listener: (context, state) {
        if (state is LoadBrandsFinishState) {
          setState(() {
            if (state.listBrands != null) {
              _listBrand.clear();
              _listBrandName.clear();
              _listBrand = state.listBrands.toList();  
              _listBrand.forEach((brand) { 
                _listBrandName.add(brand.id.toString() + ' ' + brand.name.toString());
              });
              _brandValue = _listBrandName[0].toString();
              _isLoadBrand = true;
              int id = int.parse(_brandValue.split(' ')[0]);
              _isLoadStore = false;
              _brandBloc.add(LoadBrandStores(id: id));
            }
          });
        } else if (state is LoadBrandStoresFinishState) {
          if (state.listStores != null) {
            setState(() {
              _listStore.clear();
              _listStoreName.clear();
              _listStore = state.listStores.toList();
              _listStore.forEach((store) { 
                _listStoreName.add(store.id.toString() + ' ' + store.name.toString());
              });
              if (_listStore.length != 0) {
                _storeValue = _listStoreName[0].toString();
              }
              _isLoadStore = true;
            });
          }
        }
      },
      child: SizedBox(),
    );
  }

  Widget assetBlocListener() {
    return BlocListener(
      bloc: _assetBloc,
      listener: (BuildContext context,AssetState state) async {
        if (state is LoadAuthenticatorAssetFinishState) {
          final prefs = await SharedPreferences.getInstance();
          if (state.asset != null) {
            setState(() {
              _isLogin = false;
              currentAsset = state.asset;
              prefs.setString(Config.currentAssetSave, jsonEncode(currentAsset));
            });
          } else {
            final prefs = await SharedPreferences.getInstance();
            setState(() {
              _isLogin = false;
              prefs.remove(Config.currentAssetSave);
              _isLoginFail = true;
            });
          }
        }
      },
      child: SizedBox(),
    );
  }

  Widget _headerWidget(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.025,
      right: MediaQuery.of(context).size.width * 0.05,
      left: MediaQuery.of(context).size.width * 0.05,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Image.asset(
                Config.logoOfficialPng,
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
            Container(
              child: Text(
                'Trade zone asset',
                style: TextStyle(
                  fontSize: Config.textSizeMedium,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetWidget(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.1,
      right: MediaQuery.of(context).size.width * 0.05,
      left: MediaQuery.of(context).size.width * 0.05,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black12,
            width: MediaQuery.of(context).size.height * 0.00125,
          ),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.05,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 4), 
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Asset details',
              style: TextStyle(
                fontSize: Config.textSizeSmall * 1.35,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.0125,),
            Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01,
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              width: MediaQuery.of(context).size.width,
              child: Text(
                'Brand',
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  color: Colors.black54,
                ),
              ),
            ),
            _listBrandDropDownWiget(context),
            SizedBox(height: MediaQuery.of(context).size.height * 0.0125,),
            if (_isLoadBrand) Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01,
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              width: MediaQuery.of(context).size.width,
              child: Text(
                'Store',
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  color: Colors.black54,
                ),
              ),
            ),
            if (_isLoadBrand) _listStoreDropDownWiget(context),
            if (_isLoadBrand) SizedBox(height: MediaQuery.of(context).size.height * 0.0125,),
            if (_isLoadStore && (_listStore.length > 0 || currentAsset != null)) Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01,
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              width: MediaQuery.of(context).size.width,
              child: Text(
                'Asset Code',
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  color: Colors.black54,
                ),
              ),
            ),
            if (_isLoadStore && (_listStore.length > 0 || currentAsset != null)) _codeInputText(context),
            if (_isLoadStore && (_listStore.length > 0 || currentAsset != null)) SizedBox(height: MediaQuery.of(context).size.height * 0.0125,),
            if (_isLoadStore && currentAsset != null) Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.01,
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              width: MediaQuery.of(context).size.width,
              child: Text(
                'Type',
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                  color: Colors.black54,
                ),
              ),
            ),
            if (_isLoadStore && currentAsset != null) _typeWidget(context),
            if (_isLoadStore && currentAsset != null) SizedBox(height: MediaQuery.of(context).size.height * 0.0125,),
            if (_isLoginFail) _loginFailWidget(context),
            if (_isLoginFail) SizedBox(height: MediaQuery.of(context).size.height * 0.0125,),
            if (_isLoadStore && _listStore.length > 0 && currentAsset == null) _submitButton(context),
            if (currentAsset != null) _logoutButton(context),
          ],
        ),
      )
    );
  }

  Widget _loadingWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: Config.thirdColor,
          valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
        ),
      ),
    );
  }

  Widget _postingWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              backgroundColor: Config.thirdColor,
              valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
            ),
            Text('Posting...')
          ],
        )
      ),
    );
  }

  Widget _listBrandDropDownWiget(context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
        top: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      width: MediaQuery.of(context).size.width,
      child: currentAsset == null 
        ? _isLoadBrand
          ? Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.25),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
              color: Colors.white,
              border: Border.all(
                color: Colors.black12,
              ),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.02,
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.06,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _brandValue,
                icon: Icon(Icons.arrow_drop_down, color: Colors.black87,),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: Config.textSizeSmall,
                ),
                dropdownColor: Colors.white,
                onChanged: (String newValue) {
                  _onChangeBrand(newValue);
                },
                items: _listBrandName.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.substring(value.indexOf(' '), value.length)),
                  );
                }).toList(),
              ),
            ),
          )
          : _loadingWidget(context)
        : Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            currentAsset.brandName,
            style: TextStyle(
              fontSize: Config.textSizeSmall,
              color: Colors.black,
            ),
          ),
        ),
    );
  }

  Widget _listStoreDropDownWiget(context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
        top: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      width: MediaQuery.of(context).size.width,
      child: currentAsset == null 
        ? _isLoadStore
          ? _listStore.length > 0
            ? Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
                border: Border.all(
                  color: Colors.black12,
                ),
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.02,
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _storeValue,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black87,),
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: Config.textSizeSmall,
                  ),
                  dropdownColor: Colors.white,
                  onChanged: (String newValue) {
                    setState(() {
                      _storeValue = newValue;
                    });
                  },
                  items: _listStoreName.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.substring(value.indexOf(' '), value.length)),
                    );
                  }).toList(),
                ),
              ),
            ) 
            : _noStoreWidget(context)
          : _loadingWidget(context)
        : Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            currentAsset.storeName,
            style: TextStyle(
              fontSize: Config.textSizeSmall,
              color: Colors.black,
            ),
          ),
        ),
    );
  }

  Widget _codeInputText(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.005,
        top: MediaQuery.of(context).size.height * 0.005,
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      width: MediaQuery.of(context).size.width,
      child: currentAsset == null
        ? TextField(
          autofocus: false,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            fontSize: Config.textSizeSmall,
          ),
          decoration: InputDecoration(
            alignLabelWithHint: false,
            errorStyle: TextStyle(
              color: Colors.red,
              fontSize: Config.textSizeSuperSmall,
            ),
            labelStyle: TextStyle(
              color: Config.secondColor,
              fontSize: Config.textSizeSuperSmall
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black12,
              ),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.02,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black12,
              ),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.02,
              ),
            ),
            hintText: "Input the asset code",
          ),
          controller: _assetCodeController,
        ) 
        : Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            currentAsset.id,
            style: TextStyle(
              fontSize: Config.textSizeSmall,
              color: Colors.black,
            ),
          ),
        ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return RaisedButton(
      onPressed: !_isLogin 
        ? () {
          setState(() {
            _isLogin = true;
          });
          int brandId = int.parse(_brandValue.split(' ')[0]);
          int storeId = int.parse(_storeValue.split(' ')[0]);
          String assetCode = '';
          if (_assetCodeController.text != null) {
            assetCode = _assetCodeController.text.trim().toString();
          }
          _assetBloc.add(AuthenticateAsset(brandId: brandId, storeId: storeId, assetId: assetCode));
        } 
        : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.02,
        ),
      ),
      color: Config.secondColor,
      disabledColor: Config.secondColor.withOpacity(0.5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width * 0.2,
        alignment: Alignment.center,
        child: Text(
          'Submit',
          style: TextStyle(
            fontSize: Config.textSizeSmall,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _noStoreWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
        top: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Text(
        'No store available',
        style: TextStyle(
          fontSize: Config.textSizeSmall,
        ),
      ),
    );
  }

  Widget _loginFailWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
        top: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Text(
        'Asset code is wrong or connection fail !',
        style: TextStyle(
          fontSize: Config.textSizeSmall,
          color: Colors.redAccent,
        ),
      ), 
    );
  }

  Widget _logoutButton(BuildContext context) {
    return RaisedButton(
      onPressed: () async{
        final prefs = await SharedPreferences.getInstance();
        prefs.remove(Config.currentAssetSave);
        setState(() {
          currentAsset = null;
          _isLoadBrand = false;
          _isLoadStore = false;
          _isLogin = false;
          _isLoginFail = false;
          _assetCodeController.text = '';
          _brandBloc.add(LoadBrands());
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.02,
        ),
      ),
      color: Config.secondColor,
      disabledColor: Config.secondColor.withOpacity(0.5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width * 0.2,
        alignment: Alignment.center,
        child: Text(
          'Cancel',
          style: TextStyle(
            fontSize: Config.textSizeSmall,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _typeWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.005,
        top: MediaQuery.of(context).size.height * 0.005,
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      width: MediaQuery.of(context).size.width,
      child: Text(
        currentAsset.type == 1 || currentAsset.type == 2 ? currentAsset.type == 1 ? 'Motocycle' : 'Truck' : 'Other',
        style: TextStyle(
          fontSize: Config.textSizeSmall,
        ),
      ),
    );
  }

  Widget _postWidget(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.75,
      right: MediaQuery.of(context).size.width * 0.05,
      left: MediaQuery.of(context).size.width * 0.05,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black12,
            width: MediaQuery.of(context).size.height * 0.00125,
          ),
          borderRadius: BorderRadius.circular(
            MediaQuery.of(context).size.width * 0.05,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 4), 
            ),
          ],
        ),
        child: Column(
          children: [
            if (_isPosting) _postingWidget(context),
            _postButton(context),
          ],
        ),
      ),
    );
  }

  Widget _postButton(BuildContext context) {
    return RaisedButton(
      onPressed: !_isPosting
        ? () {
          setState(() {
            _isPosting = true;
            setUpTimeFetch();
          });
          
        }
        : () {
          setState(() {
            _isPosting = false;
            _timerPostingLocation.cancel();
          });
        },
      color: Config.secondColor,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.02,
        ),
      ),
      child: Text(
        !_isPosting ? 'Post location' : 'Stop posting',
        style: TextStyle(
          fontSize: Config.textSizeSmall,
        ),
      ),
    );
  }

  void _onChangeBrand(String value) {
    setState(() {
      _brandValue = value;
      _isLoadStore = false;
      int id = int.parse(_brandValue.split(' ')[0]);
      _brandBloc.add(LoadBrandStores(id: id));
    });
  }

  _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    LatLng currentPosition;
    await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position) {
      currentPosition = LatLng(position.latitude, position.longitude);
    }).catchError((e) {
      print(e);
    });
    return currentPosition;
  }

  setUpTimeFetch() {
    _timerPostingLocation =
        Timer.periodic(Duration(milliseconds: 3000), (_timerPostingLocation) async {
      dynamic rs = await _getCurrentLocation();
      LatLng point = new LatLng(rs.latitude, rs.longitude);
      _assetProvider.postLocation(point);
    });
  }
}