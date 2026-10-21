// flutter run -d <iOS simulator ID> -t tool/mediation_simulator_test.dart
// Select each network in Ad Inspector single-source testing before loading.
import 'unity_ads_device_test.dart' show runMediationQa;

Future<void> main() => runMediationQa(chooseSource: true);
