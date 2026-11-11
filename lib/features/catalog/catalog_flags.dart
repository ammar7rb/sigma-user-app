/// Screens that the customer spec requires before the website exposes a
/// customer API. Turn off with `--dart-define=SIGMA_UNRELEASED_CATALOGS=false`.
class UnreleasedCatalogs {
  static const enabled = bool.fromEnvironment(
    'SIGMA_UNRELEASED_CATALOGS',
    defaultValue: true,
  );
}
