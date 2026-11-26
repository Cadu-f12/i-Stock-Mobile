/// Authenticated values returned by a successful login.
///
/// The OpenAPI response defines `accessToken` and `tokenType`. It does not
/// expose an expiration field, so expiration is not inferred by this model.
class LoginSession {
  const LoginSession({required this.accessToken, required this.tokenType});

  final String accessToken;
  final String tokenType;
}
