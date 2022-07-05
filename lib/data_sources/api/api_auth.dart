import 'package:survey/data_sources/api/constants.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class ApiAuth {
  Future<String> login(
      {required String username, required String password}) async {
    final authorizationEndpoint = Uri.parse(ApiConstants.authorizationEndpoint);
    final clientId = ApiConstants.clientId;
    final secret = ApiConstants.clientSecret;
    final Iterable<String> scope = {ApiConstants.scope};

    var client = await oauth2.resourceOwnerPasswordGrant(
        authorizationEndpoint, username, password,
        identifier: clientId, secret: secret, scopes: scope);
    return client.credentials.accessToken;
  }
}
