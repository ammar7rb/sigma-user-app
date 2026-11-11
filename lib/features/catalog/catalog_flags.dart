/// Medical-device and credit screens. Routes match bahaa PR #2 and are not
/// on production until that draft merges. Hide them with
/// `--dart-define=SIGMA_UNRELEASED_CATALOGS=false`.
class UnreleasedCatalogs {
  static const enabled = bool.fromEnvironment(
    'SIGMA_UNRELEASED_CATALOGS',
    defaultValue: true,
  );
}
