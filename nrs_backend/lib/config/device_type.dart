// ignore_for_file: public_member_api_docs

/// Valid device types in the system
abstract class DeviceType {
  static const String notebook = 'notebook';
  static const String tv = 'tv';

  static const List<String> validTypes = [notebook, tv];

  static bool isValid(String type) => validTypes.contains(type);
}
