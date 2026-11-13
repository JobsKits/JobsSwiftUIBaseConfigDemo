#!/usr/bin/env ruby
# JOBS_TERMINAL_STYLE_GUARD_V1_BEGIN
if $PROGRAM_NAME == __FILE__
  # 直接运行时由 fork 父进程保护配色；子进程继续原文件，不重放 Ruby 参数和预载模块。
  def jobs_terminal_style_bootstrap_v1
    return unless $PROGRAM_NAME == __FILE__
    plain = lambda do
      ENV.update('PLAIN_OUTPUT' => '1', 'NO_COLOR' => '1', 'FORCE_COLOR' => '0',
                 'CLICOLOR' => '0', 'ANSI_COLORS_DISABLED' => '1', 'npm_config_color' => 'false')
    end
    notify = lambda do |message|
      encoding = $stderr.external_encoding || Encoding::UTF_8
      $stderr.write((message + "\n").encode(encoding, invalid: :replace, undef: :replace))
    end
    return unless $stdin.tty? && $stdout.tty?
    return if ENV.key?('NO_COLOR') || ENV['PLAIN_OUTPUT'] == '1' ||
              ENV['IS_SOURCETREE_RUNTIME'] == '1' ||
              ENV.keys.any? { |key| key.match?(/\A(?:SOURCETREE|SOURCE_TREE)/i) }
    return if ['', 'dumb'].include?(ENV.fetch('TERM', ''))
    if File::ALT_SEPARATOR == '\\' || !Process.respond_to?(:fork) ||
       Thread.list.length > 1 || ENV['TMUX'] || ENV['STY']
      plain.call
      return
    end
    tty_name = IO.popen(['tty'], err: File::NULL, &:read).strip
    groups = IO.popen(['ps', '-o', 'pgid=', '-o', 'tpgid=', '-p', Process.pid.to_s], err: File::NULL, &:read).split
    unless tty_name.match?(%r{\A/dev/[A-Za-z0-9_./-]+\z}) && groups.length == 2 &&
           groups.all? { |group| group.match?(/\A\d+\z/) } && groups[0].to_i > 0 && groups[0] == groups[1]
      plain.call
      return
    end
    owner = ENV['JOBS_TERMINAL_STYLE_OWNER']
    if ENV['JOBS_TERMINAL_STYLE_TTY'] == tty_name && owner && owner.match?(/\A\d+\z/)
      begin
        Process.kill(0, owner.to_i)
        return
      rescue Errno::ESRCH, Errno::EPERM
      end
    end
    require 'io/console'
    require 'tmpdir'
    if Thread.list.length > 1
      plain.call
      return
    end
    tty = File.open('/dev/tty', 'r+')
    tty.binmode
    tty.sync = true
    keys = ['10', '11', '12'] + (0..15).map { |index| "4;#{index}" }
    palette = %w[000000 ff5f56 5fd787 ffd75f 5fafff d787ff 5fd7ff eeeeee
                 9e9e9e ff8787 87ffaf ffff87 87bfff ffafff afffff ffffff]
    targets = { '10' => 'ffffff', '11' => '000000', '12' => 'ffffff' }
    palette.each_with_index { |color, index| targets["4;#{index}"] = color }
    query = lambda do |key|
      tty.write("\e]#{key};?\a")
      bytes = ''.b
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 0.3
      loop do
        remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
        return nil if remaining <= 0 || !IO.select([tty], nil, nil, remaining)
        piece = tty.read_nonblock(256, exception: false)
        next if piece == :wait_readable
        return nil unless piece && !piece.empty?
        bytes << piece
        return nil if bytes.bytesize > 256 || !bytes.start_with?("\e".b)
        break if bytes.end_with?("\a".b) || bytes.end_with?("\e\\".b)
      end
      match = bytes.match(/\A\e\]#{Regexp.escape(key)};rgb:([0-9a-fA-F]{1,4})\/([0-9a-fA-F]{1,4})\/([0-9a-fA-F]{1,4})(?:\a|\e\\)\z/n)
      return nil unless match
      components = match.captures.map { |hex| (hex.to_i(16) * 65535.0 / (16**hex.length - 1)).round }
      { raw: bytes, rgb: components }
    rescue IOError, SystemCallError
      nil
    end
    snapshot = lambda do
      values = {}
      tty.raw(min: 0, time: 0, intr: true) do
        keys.each do |key|
          value = query.call(key)
          return nil unless value
          values[key] = value
        end
      end
      values
    rescue IOError, SystemCallError, ArgumentError
      nil
    end
    original = snapshot.call
    unless original
      notify.call('终端不支持完整配色保存，或启动时收到其它输入；保留原配色并使用纯文本。')
      tty.close
      plain.call
      return
    end
    directory = Dir.mktmpdir('jobs-terminal-style-')
    recovery = File.join(directory, 'restore.sh')
    original_bytes = keys.map { |key| original.fetch(key).fetch(:raw) }.join
    recovery_source = "#!/bin/sh\n" \
      "[ -t 0 ] && [ \"$(tty)\" = '#{tty_name}' ] || { printf '请在原终端运行恢复入口。\\n' >&2; exit 1; }\n" \
      "printf '本操作会覆盖此终端当前配色。确认恢复脚本启动前的配色，请输入 YES：' >&2\n" \
      "IFS= read -r jobs_restore_choice\n[ \"$jobs_restore_choice\" = YES ] || exit 1\n" \
      "printf '%s\\033[0m' '#{original_bytes}' > /dev/tty\n"
    File.open(recovery, File::WRONLY | File::CREAT | File::EXCL, 0o600) do |file|
      file.binmode
      file.write(recovery_source.b)
    end
    notify.call("本次终端临时使用黑底白字；强退后恢复入口：sh \"#{recovery}\"")
    changed = false
    applied = nil
    # 比较仍生效的本轮颜色，只恢复未被用户另行修改的项。
    cleanup = lambda do
      current = applied && snapshot.call
      unless current
        notify.call("终端配色未能安全自动恢复；确认覆盖当前配色后可运行：sh \"#{recovery}\"")
        return false
      end
      conflicts = []
      restore_bytes = ''.b
      keys.each do |key|
        if current.fetch(key).fetch(:rgb) == applied.fetch(key).fetch(:rgb)
          restore_bytes << original.fetch(key).fetch(:raw)
        else
          conflicts << key
        end
      end
      tty.write(restore_bytes + "\e[0m".b)
      if conflicts.empty?
        File.unlink(recovery)
        Dir.rmdir(directory)
        true
      else
        notify.call("检测到运行期间的配色变更，已保留这些项：#{conflicts.join(' ')}")
        notify.call("确认要覆盖后续改色时才使用恢复入口：sh \"#{recovery}\"")
        false
      end
    rescue IOError, SystemCallError
      notify.call("终端配色未能安全自动恢复；确认覆盖当前配色后可运行：sh \"#{recovery}\"")
      false
    end
    child_pid = nil
    guardian = false
    interrupted = nil
    previous_signals = {}
    %w[INT TERM HUP].each do |name|
      previous_signals[name] = Signal.trap(name) do
        interrupted = name
        if child_pid && name != 'INT'
          begin
            Process.kill(name, child_pid)
          rescue Errno::ESRCH
          end
        end
      end
    end
    begin
      changed = true
      tty.write(targets.map { |key, color| "\e]#{key};##{color}\a" }.join + "\e[0m")
      applied = snapshot.call
      unless applied
        notify.call('无法核实本次临时配色，已停止启动业务。')
        raise SystemExit, 1
      end
      desired = targets.all? do |key, hex|
        rgb = hex.scan(/../).map { |component| component.to_i(16) * 257 }
        applied.fetch(key).fetch(:rgb).zip(rgb).all? { |actual, expected| (actual - expected).abs <= 255 }
      end
      unless desired
        notify.call('终端未接受本次配色，恢复后使用纯文本。')
        restored = cleanup.call
        changed = false
        raise SystemExit, 1 unless restored
        plain.call
        return
      end
      if interrupted
        raise SystemExit, 128 + Signal.list.fetch(interrupted)
      end
      if Thread.list.length > 1
        restored = cleanup.call
        changed = false
        raise SystemExit, 1 unless restored
        plain.call
        return
      end
      $stdout.flush
      $stderr.flush
      begin
        child_pid = Process.fork
      rescue NotImplementedError, SystemCallError
        restored = cleanup.call
        changed = false
        raise SystemExit, 1 unless restored
        plain.call
        return
      end
      unless child_pid
        changed = false
        ENV['JOBS_TERMINAL_STYLE_TTY'] = tty_name
        ENV['JOBS_TERMINAL_STYLE_OWNER'] = Process.ppid.to_s
        raise SystemExit, 128 + Signal.list.fetch(interrupted) if interrupted
        return
      end
      guardian = true
      result = nil
      loop do
        begin
          _, result = Process.wait2(child_pid)
          break
        rescue Interrupt, Errno::EINTR
        end
      end
      status_code = result.exitstatus || 128 + result.termsig
      %w[INT TERM HUP].each { |name| Signal.trap(name, 'IGNORE') }
      restored = cleanup.call
      changed = false
      status_code = 1 if !restored && status_code.zero?
      tty.close
      Process.exit!(status_code)
    ensure
      if changed
        %w[INT TERM HUP].each { |name| Signal.trap(name, 'IGNORE') }
        cleanup.call
      end
      previous_signals.each { |name, handler| Signal.trap(name, handler) } unless guardian
      tty.close unless tty.closed?
    end
  rescue IOError, SystemCallError, LoadError => error
    if guardian
      notify.call("终端保护监督进程异常：#{error.message}")
      Process.exit!(1)
    end
    raise SystemExit, 1 if changed
    notify.call("终端保护不可用，使用纯文本：#{error.message}")
    plain.call
  end
  jobs_terminal_style_bootstrap_v1

end
# JOBS_TERMINAL_STYLE_GUARD_V1_END

require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'shellwords'
require 'tmpdir'

# 用途：验证 IPA 留存的签名分支、成功后输出替换、失败时旧产物保护，以及 Xcode 打包阶段的挂载位置。
# 运行：在本文件目录执行 ruby ./run_regression.rb --run；需要完整工程目录及 macOS 打包工具。
# 边界：临时 App 与假签名器只处理隔离夹具，不构建工程、不调用真实签名身份、不安装 App；仅供打包脚本回归。

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
