Pod::Spec.new do |s|
  s.name = 'iSphinx'
  s.version = '1.1.1'
  s.license = 'MIT'
  s.summary = 'iOS library with swift for offline speech recognition base on Pocketsphinx engine.'
  s.homepage = 'https://github.com/icaksama/iSphinx'
  s.social_media_url = 'https://twitter.com/icaksama'
  s.social_media_url = 'https://www.facebook.com/icaksama.fanpage'
  s.authors = { 'icaksama' => 'icaksama@gmail.org' }
  s.source = { :git => 'https://github.com/icaksama/iSphinx.git', :tag => s.version }
  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.framework = 'Foundation', 'CoreAudio', 'AVFoundation', 'Sphinx', 'CoreMedia'
  #s.libraries = 'pocketsphinx', 'sphinxbase', 'sphinxad'
  #s.vendored_libraries = 'iSphinx/Sphinx/lib/pocketsphinx/libpocketsphinx.a', 'iSphinx/Sphinx/lib/pocketsphinx/libsphinxbase.a', 'iSphinx/Sphinx/lib/pocketsphinx/libsphinxad.a'
  #s.compiler_flags = {'iSphinx/iSphinx/Assets/*.{dict}' => '-w'}
  #s.preserve_path = 'iSphinx/iSphinx/Assets/*', 'iSphinx/iSphinx/Assets/en-us-ptm/*'
  s.source_files = 'iSphinx/iSphinx/*.{swift,h}',
                   'iSphinx/iSphinx/iSphinx Utilities/*.{swift}',
                   'iSphinx/Sphinx/include/**/*.{h}',
                   'iSphinx/Sphinx/lib/**/*.{a}',
                   'iSphinx/Sphinx/lib/**/**/*.{a}',
                   'iSphinx/iSphinx/Assets/*',
                   'iSphinx/iSphinx/Assets/en-us-ptm/*'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0',
                            'HEADER_SEARCH_PATHS' => '${PODS_TARGET_SRCROOT}/iSphinx/Sphinx/Include/**',
                            'SWIFT_INCLUDE_PATHS' => '${PODS_TARGET_SRCROOT}/iSphinx/Sphinx/Include',
                            'LIBRARY_SEARCH_PATHS' => '${PODS_TARGET_SRCROOT}/iSphinx/Sphinx/lib/pocketsphinx ${PODS_TARGET_SRCROOT}/iSphinx/Sphinx/lib/sphinxbase',
                            'OTHER_LDFLAGS' => '-lObjC -lsphinxbase -lsphinxad -lpocketsphinx'
                          }
end
