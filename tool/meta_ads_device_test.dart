// iOS QA only. Profile builds require native META_ADS_QA.
// In Ad Inspector enable Meta Audience Network (Bidding) single-source testing.
import 'unity_ads_device_test.dart' show runMediationQa;

Future<void> main() => runMediationQa(meta: true);
