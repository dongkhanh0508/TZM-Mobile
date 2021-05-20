class Asset {
  String id;
  String name;
  int type;
  int storeId;
  String storeName;
  int brandId;
  String brandName;
  bool isDeleted;

  Asset(
      {this.id,
      this.name,
      this.type,
      this.storeId,
      this.storeName,
      this.brandId,
      this.brandName,
      this.isDeleted});

  Asset.fromJson(Map<String, dynamic> json) {
    id = json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
    name = json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'];
    json['Type'] != null ? type = int.parse(json['Type']) : type = null;
    json['StoreId'] != null ? storeId = int.parse(json['StoreId']) : storeId = null;
    storeName = json['StoreName'];
    json['BrandId'] != null ? brandId = int.parse(json['BrandId']) : brandId = null;
    brandName = json['BrandName'];
    isDeleted = json['isDeleted'];
  }

  Asset.fromJsonSave(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    storeId = json['storeId'];
    storeName = json['storeName'];
    brandId = json['brandId'];
    brandName = json['brandName'];
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data['storeId'] = this.storeId;
    data['storeName'] = this.storeName;
    data['brandId'] = this.brandId;
    data['brandName'] = this.brandName;
    data['isDeleted'] = this.isDeleted;
    return data;
  }
}
