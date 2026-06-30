Pod::Spec.new do |spec|
  spec.name         = 'JobsSwiftUICodeGraphHook'
  spec.version      = '1.0.0'
  spec.summary      = 'CodeGraph hook anchor for JobsSwiftUIBaseConfigDemo.'
  spec.description  = 'A no-op local Pod used only to keep CocoaPods install lifecycle available for CodeGraph scripts.'
  spec.homepage     = 'https://example.local/JobsSwiftUICodeGraphHook'
  spec.license      = { :type => 'MIT', :text => 'MIT' }
  spec.author       = { 'Jobs' => 'lg295060456@gmail.com' }
  spec.platform     = :ios, '17.0'
  spec.requires_arc = true
  spec.source       = { :path => '.' }
  spec.source_files = 'Sources/**/*.swift'
  spec.swift_version = '5.0'
end
