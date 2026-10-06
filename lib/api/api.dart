import 'package:cura/core/config/app_config.dart';

Uri buildApiUri(String endpoint) {
  return Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
}
