// Opt-in iOS QA host. Profile requires native META_ADS_QA and UNITY_ADS_QA.
import 'package:flutter/material.dart';
import 'ios_ads_regression_device_test.dart' show AdsRegressionQa;
import 'unity_ads_device_test.dart' show runMediationQa;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('iOS Ads Device QA')),
        body: Column(
          children: [
            TextButton(
              onPressed: () =>
                  runApp(const MaterialApp(home: AdsRegressionQa())),
              child: const Text('Test production ad service'),
            ),
            TextButton(
              onPressed: () => runMediationQa(meta: true),
              child: const Text('Test Meta'),
            ),
            TextButton(
              onPressed: () => runMediationQa(),
              child: const Text('Test Unity'),
            ),
          ],
        ),
      ),
    ),
  );
}
