Pod::Spec.new do |s|
  s.name = 'iSphinx'
  s.version = '1.1.1'
  s.license = 'MIT'
  s.summary = 'iOS library with swift for offline speech recognition base on Pocketsphinx engine.'
  s.homepage = 'https://github.com/icaksama/iSphinx'
  s.social_media_url = 'http://twitter.com/icaksama'
  s.authors = { 'icaksama' => 'icaksama@gmail.org' }
  s.source = { :git => 'https://github.com/icaksama/iSphinx.git', :tag => s.version }
  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  s.source_files = 'iSphinx/iSphinx/*.{swift,h}',
                   'iSphinx/iSphinx/iSphinx Utilities/*.{swift}',
                   'iSphinx/iSphinx/Assets/*.{arpa,dict,wav}',
                   'iSphinx/iSphinx/Assets/en-us-ptm/*.{params}',
                   'iSphinx/iSphinx/Assets/en-us-ptm/*',
                   'iSphinx/Sphinx/include/*.{modulemap}',
                   'iSphinx/Sphinx/include/**/*.{h}',
                   'iSphinx/Sphinx/lib/**/*.{a}',
                   'iSphinx/Sphinx/lib/**/**/*.{a}'
end
