Pod::Spec.new do |s|
  s.name = 'iSphinx'
  s.version = '1.1.5'
  s.license = 'MIT'
  s.summary = 'iOS library with swift for offline speech recognition base on Pocketsphinx engine.'
  s.homepage = 'https://github.com/icaksama/iSphinx'
  s.social_media_url = 'https://twitter.com/icaksama'
  s.social_media_url = 'https://www.facebook.com/icaksama.fanpage'
  s.authors = { 'icaksama' => 'icaksama@gmail.com' }
  s.source = { :git => 'https://github.com/icaksama/iSphinx.git', :tag => s.version }
  s.platform = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.frameworks = 'Foundation', 'CoreAudio', 'AVFoundation', 'CoreMedia'
  s.preserve_paths = 'iSphinx/Sphinx/include/**/*.{h}', 'iSphinx/Sphinx/include/*.{modulemap}'
  s.vendored_libraries = 'iSphinx/Sphinx/lib/pocketsphinx/libpocketsphinx.a', 'iSphinx/Sphinx/lib/sphinxbase/libsphinxbase.a'
  s.libraries = 'pocketsphinx', 'sphinxbase'
  s.resource_bundles = { 'Assets' => ['iSphinx/iSphinx/Assets/*.{arpa,wav,txt}'],
                         'AcousticModel' => 'iSphinx/iSphinx/Assets/en-us-ptm/*' }
  s.source_files = 'iSphinx/iSphinx/*.{swift,h}',
                   'iSphinx/iSphinx/iSphinx Utilities/*.{swift}'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0',
                            'ENABLE_BITCODE' => 'NO',
                            'SWIFT_OPTIMIZATION_LEVEL' => '-Onone',
                            'EXCLUDED_SOURCE_FILE_NAMES' => 'cmudict-en-us.dict',
                            'HEADER_SEARCH_PATHS' => '${PODS_TARGET_SRCROOT}/iSphinx/Sphinx/Include/**',
                            'SWIFT_INCLUDE_PATHS' => '${PODS_TARGET_SRCROOT}/iSphinx/Sphinx/Include',
                            'LIBRARY_SEARCH_PATHS' => '${PODS_TARGET_SRCROOT}/iSphinx/Sphinx/lib/pocketsphinx ${PODS_TARGET_SRCROOT}/iSphinx/Sphinx/lib/sphinxbase',
                            'OTHER_LDFLAGS' => '-lObjC -lC -lsphinxbase -lpocketsphinx'
                          }
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_TARGET_SRCROOT}/iSphinx/Sphinx/Include/**",
                 'SWIFT_OPTIMIZATION_LEVEL' => '$(inherited)',
                 'ENABLE_BITCODE' => '$(inherited)'
               }
end
