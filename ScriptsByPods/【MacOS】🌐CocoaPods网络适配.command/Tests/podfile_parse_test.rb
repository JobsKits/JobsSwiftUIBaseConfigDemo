# frozen_string_literal: true

# 用真实 CocoaPods 解析完整 Podfile，不运行安装、hook 或联网测试。
require 'cocoapods'
require 'digest'

project_root = File.expand_path('../../..', __dir__)
inputs = %w[Podfile Podfile.deps Podfile.lock Pods/Manifest.lock].map do |path|
  File.join(project_root, path)
end
fingerprints = inputs.to_h do |path|
  [path, File.file?(path) ? Digest::SHA256.file(path).hexdigest : nil]
end

ARGV.clear
Pod::Config.instance.installation_root = Pathname.new(project_root)
podfile = Pod::Podfile.from_file(Pathname.new(project_root).join('Podfile'))
raise '公共源声明不唯一' unless podfile.sources.length == 1
raise '公共源不是已允许的官方来源' unless JobsCocoaPodsSource::SOURCE_URLS.include?(podfile.sources.first)

target = podfile.target_definitions.fetch('JobsSwiftUIBaseConfigDemo')
expected_dependencies = %w[JobsSwiftUICodeGraphHook JobsSwiftUIDebugPanel]
raise '原有本地依赖被改变' unless target.dependencies.map(&:name) == expected_dependencies
expected_dependencies.each do |name|
  dependency = target.dependencies.find { |value| value.name == name }
  raise "本地路径失效：#{name}" unless File.directory?(File.join(project_root, dependency.external_source.fetch(:path)))
end
raise '原有 post_install 未保留' unless podfile.instance_variable_get(:@post_install_callback)
raise '原有 post_integrate 未保留' unless podfile.instance_variable_get(:@post_integrate_callback)
fingerprints.each do |path, original|
  current = File.file?(path) ? Digest::SHA256.file(path).hexdigest : nil
  raise "只读解析改写了文件：#{path}" unless current == original
end
puts 'PASS 完整 Podfile 真实解析、唯一官方源、本地依赖、原 hooks 与锁文件不变'
