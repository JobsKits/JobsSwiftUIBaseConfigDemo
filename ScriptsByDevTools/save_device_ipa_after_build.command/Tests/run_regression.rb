#!/usr/bin/env ruby
# 使用临时 App 与假签名器验证 IPA 留存；不构建工程、不调用真实签名身份、不安装 App。
require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'shellwords'
require 'tmpdir'

abort '用法：ruby run_regression.rb --run（仅临时夹具）' unless ARGV == ['--run']
package_root = File.expand_path('..', __dir__)
project_root = File.expand_path('../../..', __dir__)
script_path = File.join(package_root, 'save_device_ipa_after_build.command')
total = 0

# 对旧输出目录建立内容快照，失败分支必须逐项保持原样。
def snapshot(directory)
  Dir.glob(File.join(directory, '**', '*'), File::FNM_DOTMATCH).reject do |path|
    ['.', '..'].include?(File.basename(path))
  end.sort.map do |path|
    [path.sub(directory, ''), File.file?(path) ? Digest::SHA256.file(path).hexdigest : 'directory']
  end
end

Dir.mktmpdir('jobs-swiftui-ipa-') do |temporary|
  fixture = File.join(temporary, 'project with spaces')
  products = File.join(temporary, 'DerivedData', 'Products')
  temporary_logs = File.join(temporary, 'runtime')
  fake_bin = File.join(temporary, 'fake bin')
  FileUtils.mkdir_p([fixture, products, temporary_logs, fake_bin])
  trace = File.join(temporary, 'sign.log')
  complete = File.join(temporary, 'signed')
  fake_signer = File.join(fake_bin, 'fixture_codesign')
  File.write(fake_signer, <<~'SHELL')
    #!/bin/zsh
    print -r -- "$*" >> "$TEST_SIGN_TRACE"
    case "$1" in
      --verify)
        [[ "$TEST_SIGNATURE_MODE" != fail ]] || exit 9
        [[ "$TEST_SIGNATURE_MODE" != resign || -f "$TEST_SIGN_COMPLETE" ]]
        ;;
      --force)
        [[ "$TEST_SIGNATURE_MODE" != fail ]] || exit 9
        print -r -- signed > "$TEST_SIGN_COMPLETE"
        ;;
      *) exit 99 ;;
    esac
  SHELL
  fake_ditto = File.join(fake_bin, 'ditto')
  File.write(fake_ditto, <<~'SHELL')
    #!/bin/zsh
    [[ "$TEST_FAIL_ZIP" != 1 || "$1" != -c ]] || exit 7
    exec /usr/bin/ditto "$@"
  SHELL
  FileUtils.chmod(0755, [fake_signer, fake_ditto])
  runner = File.join(temporary, 'fixture_runner.command')
  File.write(runner, File.read(script_path).gsub('/usr/bin/codesign', Shellwords.escape(fake_signer)))
  app = File.join(products, 'FixtureSwiftUI.app')
  FileUtils.mkdir_p(app)
  File.write(File.join(app, 'Info.plist'), '<plist><dict><key>CFBundleExecutable</key><string>FixtureSwiftUI</string></dict></plist>')
  File.write(File.join(app, 'FixtureSwiftUI'), 'fixture only; not executable code')
  build = File.join(fixture, 'build')
  environment = {
    'PATH' => "#{fake_bin}:/usr/bin:/bin:/usr/sbin:/sbin",
    'XCODE_VERSION_ACTUAL' => '1700', 'SRCROOT' => fixture,
    'TARGET_BUILD_DIR' => products, 'WRAPPER_NAME' => 'FixtureSwiftUI.app',
    'PRODUCT_TYPE' => 'com.apple.product-type.application', 'ACTION' => 'build',
    'TMPDIR' => temporary_logs, 'NO_COLOR' => '1',
    'TEST_SIGN_TRACE' => trace, 'TEST_SIGN_COMPLETE' => complete,
    'TEST_SIGNATURE_MODE' => 'valid', 'TEST_FAIL_ZIP' => '0',
    'CODE_SIGNING_ALLOWED' => 'NO', 'EXPANDED_CODE_SIGN_IDENTITY' => nil,
    'PROJECT_TEMP_DIR' => nil, 'BUILD_DIR' => nil, 'OBJROOT' => nil,
    'SYMROOT' => nil, 'DERIVED_DATA_DIR' => nil
  }
  cases = [
    ['无签名模拟器留存', {'PLATFORM_NAME' => 'iphonesimulator'}, '模拟器.ipa'],
    ['有效真机签名原样保留', {'PLATFORM_NAME' => 'iphoneos', 'CODE_SIGNING_ALLOWED' => 'YES', 'EXPANDED_CODE_SIGN_IDENTITY' => 'fixture identity'}, '真机.ipa'],
    ['真机快照补签及复检', {'PLATFORM_NAME' => 'iphoneos', 'CODE_SIGNING_ALLOWED' => 'YES', 'EXPANDED_CODE_SIGN_IDENTITY' => 'fixture identity', 'TEST_SIGNATURE_MODE' => 'resign'}, '真机.ipa'],
    ['真机缺身份拒绝且旧产物保留', {'PLATFORM_NAME' => 'iphoneos', 'CODE_SIGNING_ALLOWED' => 'YES'}, :failure],
    ['真机签名失败旧产物保留', {'PLATFORM_NAME' => 'iphoneos', 'CODE_SIGNING_ALLOWED' => 'YES', 'EXPANDED_CODE_SIGN_IDENTITY' => 'fixture identity', 'TEST_SIGNATURE_MODE' => 'fail'}, :failure],
    ['压缩失败旧产物保留', {'PLATFORM_NAME' => 'iphonesimulator', 'TEST_FAIL_ZIP' => '1'}, :failure],
    ['源App缺失旧产物保留', {'PLATFORM_NAME' => 'iphonesimulator', 'WRAPPER_NAME' => 'Missing.app'}, :failure],
    ['构建目录位于build时拒绝', {'PLATFORM_NAME' => 'iphonesimulator', 'BUILD_DIR' => File.join(build, 'DerivedData')}, :failure],
    ['clean不产包', {'PLATFORM_NAME' => 'iphoneos', 'ACTION' => 'clean'}, :skip],
    ['非App不产包', {'PLATFORM_NAME' => 'iphonesimulator', 'PRODUCT_TYPE' => 'com.apple.product-type.bundle.unit-test'}, :skip],
    ['非iOS不产包', {'PLATFORM_NAME' => 'macosx'}, :skip]
  ]
  cases.each do |label, additions, expected|
    FileUtils.rm_rf(build)
    FileUtils.mkdir_p(File.join(build, 'old folder'))
    File.write(File.join(build, '.hidden'), 'hidden output')
    File.write(File.join(build, 'old.ipa'), 'old output')
    File.write(File.join(build, 'old folder', 'keep'), 'nested output')
    FileUtils.rm_f([trace, complete])
    before = snapshot(build)
    output, status = Open3.capture2e(environment.merge(additions), '/bin/zsh', runner)
    if expected == :failure || expected == :skip
      raise "#{label}：退出状态错误\n#{output}" unless status.success? == (expected == :skip)
      raise "#{label}：旧产物被改写" unless snapshot(build) == before
    else
      raise "#{label}：失败\n#{output}" unless status.success?
      raise "#{label}：未只保留本次IPA" unless Dir.children(build) == [expected]
      entries, zip_status = Open3.capture2e('/usr/bin/unzip', '-Z1', File.join(build, expected))
      raise "#{label}：Payload无效" unless zip_status.success? && entries.include?('Payload/FixtureSwiftUI.app/Info.plist')
      signs = File.exist?(trace) ? File.read(trace) : ''
      raise '模拟器不应调用签名器' if expected == '模拟器.ipa' && !signs.empty?
      raise '有效签名被重新签名' if label == '有效真机签名原样保留' && signs.include?('--force')
      if label == '真机快照补签及复检'
        raise '补签未保留签名元数据' unless signs.include?('--preserve-metadata=identifier,entitlements,requirements,flags')
        raise '补签后未复检' unless signs.scan('--verify --deep --strict').size == 2
      end
    end
    raise "#{label}：临时快照未清理" unless Dir.glob(File.join(temporary_logs, 'fixture_runner.*')).reject { |path| path.end_with?('.log') }.empty?
    total += 1
    puts "通过 #{total}：#{label}"
  end
end

project_file = File.join(project_root, 'JobsSwiftUIBaseConfigDemo.xcodeproj', 'project.pbxproj')
json, status = Open3.capture2e('/usr/bin/plutil', '-convert', 'json', '-o', '-', project_file)
raise json unless status.success?
objects = JSON.parse(json).fetch('objects')
target = objects.values.find { |object| object['isa'] == 'PBXNativeTarget' && object['name'] == 'JobsSwiftUIBaseConfigDemo' }
phases = target.fetch('buildPhases').map { |identifier| objects.fetch(identifier) }
raise 'IPA阶段不唯一或没有位于最后' unless phases.count { |phase| phase['name'] == 'Save Build IPA' } == 1 && phases.last['name'] == 'Save Build IPA'
raise 'IPA脚本路径未统一' unless phases.last.fetch('shellScript').include?('save_device_ipa_after_build.command/save_device_ipa_after_build.command')
raise '输出未声明build目录' unless phases.last.fetch('outputPaths') == ['$(SRCROOT)/build']
puts "通过 #{total += 1}：唯一主App IPA阶段位于资源复制之后，路径与输出声明正确"
puts "IPA隔离回归完成：#{total} 项通过；没有真实构建、签名或安装。"
