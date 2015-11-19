Pod::Spec.new do |s|
  s.name     = 'CLColorPicker'
  s.version  = '1.0'
  s.license  = 'Custom'
  s.summary  = 'Color picker for Yosemite'
  s.homepage = 'https://github.com/sakrist/CLColorPicker'
  s.author   = { 'Volodymyr Boichentsov' => 'https://github.com/sakrist' }
  s.source   = { :git => 'https://github.com/sakrist/CLColorPicker.git' }
  s.source_files = 'CLColorPicker/*.{h,m}', 'CLColorPicker_example/NSColor+ColorExtensions.{h,m}'
  s.requires_arc = true
  s.resources = 'CLColorPicker/*.xib', 'CLColorPicker_example/Images.xcassets/**/*.{png,jpg}'

  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
  s.osx.deployment_target = '10.9'
end
