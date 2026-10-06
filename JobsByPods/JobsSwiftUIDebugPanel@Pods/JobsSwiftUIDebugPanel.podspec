Pod::Spec.new do |spec|
  spec.name          = 'JobsSwiftUIDebugPanel'
  spec.version       = '1.0.0'
  spec.summary       = 'Debug-only scene-aware SwiftUI tools and URL environments.'
  spec.description   = 'A bundled circular SwiftUI Button pushes a List of environment and ordered custom actions in a SwiftUI NavigationStack.'
  spec.homepage      = 'https://example.local/JobsSwiftUIDebugPanel'
  spec.license       = { :type => 'MIT', :file => 'LICENSE' }
  spec.author        = { 'Jobs' => 'lg295060456@gmail.com' }
  spec.platform      = :ios, '17.0'
  spec.swift_version = '5.0'
  spec.source        = { :path => '.' }
  spec.source_files  = 'Core/**/*.swift'
  spec.resource_bundles = {
    'JobsSwiftUIDebugPanelResources' => ['Resource/*.png', 'Resource/*LICENSE*']
  }
  spec.exclude_files = ['**/.DS_Store', '**/Tests/**', '**/Examples/**', '**/build/**']
  spec.frameworks = ['SwiftUI', 'UIKit', 'Combine', 'Foundation']
  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
