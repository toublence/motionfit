Pod::Spec.new do |s|
  s.name             = 'motionfit_pose'
  s.version          = '0.0.1'
  s.summary          = 'On-device camera preview and MediaPipe pose tracking for MotionFit.'
  s.description      = <<-DESC
Provides a Flutter texture backed by AVFoundation and performs real-time,
on-device pose landmark inference without recording or uploading camera frames.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'Proprietary', :file => '../LICENSE' }
  s.author           = 'NAMSLAB'
  s.source           = { :path => '.' }

  s.source_files = 'Classes/**/*.{swift,h,m}'
  s.dependency 'Flutter'
  s.dependency 'MediaPipeTasksVision', '0.10.35'
  s.platform = :ios, '15.0'
  s.swift_version = '5.0'
  s.static_framework = true
  s.frameworks = 'AVFoundation', 'CoreMedia', 'CoreVideo', 'UIKit'

  s.resource_bundles = {
    'motionfit_pose_privacy' => ['Resources/PrivacyInfo.xcprivacy'],
    'motionfit_pose_models' => ['Assets/model_manifest.json', 'Assets/*.task']
  }

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
