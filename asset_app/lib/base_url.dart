class BaseUrl {
  static String versionApi = "v1.0";
  static String base = "https://trade-zone-team.azurewebsites.net/api/" + versionApi + "/";

  // acccounts
  static String accountsbase = base + "accounts/";
  static String authenticate = accountsbase + "authenticate";
  static String verifyJwt = accountsbase + "verify-jwt";
  static String accountbyid(String id) {
    return accountsbase + id;
  }

  // brands
  static String brandsbase = base + "brands/";
  static String listbrandstores(int id) {
    return brandsbase + id.toString() + '/stores-asset';
  }
  static String brands = base + "brands";

  // assets
  static String assetsbase = base + "assets/";
  static String authenticateassets = assetsbase + "authenticator";
  static String assetlocation = assetsbase + "Assets-Location";
}
