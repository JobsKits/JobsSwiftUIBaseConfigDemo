# pod install --repo-update
# ================================== Podfile ==================================
ENV['COCOAPODS_DISABLE_STATS'] = 'true'
require 'fileutils'
source 'https://github.com/CocoaPods/Specs.git'

install! 'cocoapods',
  :deterministic_uuids => false,
  :disable_input_output_paths => true

# ================================== Jobs Pods Script Runner ==================================
JOBS_DEPLOYMENT_TARGET = '17.0'
JOBS_DISABLE_SCRIPT_SANDBOXING = 'NO'

platform :ios, "#{JOBS_DEPLOYMENT_TARGET}"

JOBS_SCRIPTS_BY_PODS_DIR = File.expand_path('ScriptsByPods', __dir__)

# 解析 ScriptsByPods 新目录结构：
# - 旧结构：ScriptsByPods/xxx.sh
# - 新结构：ScriptsByPods/xxx.sh/xxx.sh
def jobs_resolve_external_script_path(rel_path, base_dir: __dir__)
  direct_path = File.expand_path(rel_path, base_dir)
  return direct_path if File.file?(direct_path)

  wrapped_path = File.join(File.dirname(direct_path), File.basename(direct_path), File.basename(direct_path))
  return wrapped_path if File.file?(wrapped_path)

  direct_path
end

# 按脚本 shebang 选择解释器，避免新版 zsh 脚本被 bash 强行执行。
def jobs_external_script_command(script_path)
  first_line = ''

  begin
    File.open(script_path, 'r:utf-8') { |file| first_line = file.readline.to_s.strip }
  rescue
    first_line = ''
  end

  return ['/bin/zsh', script_path] if first_line.include?('zsh') || File.extname(script_path) == '.command'
  return ['/bin/bash', script_path] if first_line.include?('bash')

  [script_path]
end

# CodeGraph: pod install 完成后在后台生成 CodeGraph 索引。
def run_codegraph_init_script
  if ENV['JOBS_SKIP_CODEGRAPH'] == '1'
    Pod::UI.puts '[CodeGraph] JOBS_SKIP_CODEGRAPH=1，已跳过本次后台同步' if defined?(Pod::UI)
    return
  end

  script_path = jobs_resolve_external_script_path(
    File.join('ScriptsByPods', 'codegraph_init.command'),
    base_dir: __dir__
  )

  unless File.file?(script_path)
    Pod::UI.puts "[CodeGraph] skip, script not found: #{script_path}" if defined?(Pod::UI)
    return
  end

  Pod::UI.puts "[CodeGraph] chmod +x #{script_path}" if defined?(Pod::UI)
  unless system('/bin/chmod', '+x', script_path)
    Pod::UI.puts "[CodeGraph] ⚠️ chmod +x 执行失败，已跳过：#{script_path}" if defined?(Pod::UI)
    return
  end

  async_log = '/tmp/codegraph_init.async.log'
  pid_dir = File.join(__dir__, '.codegraph')
  pid_path = File.join(pid_dir, 'codegraph_init.pid')
  existing_pid = Integer(File.read(pid_path).strip, exception: false) if File.file?(pid_path)

  if existing_pid
    begin
      Process.kill(0, existing_pid)
      Pod::UI.puts "[CodeGraph] 后台同步已在运行，PID=#{existing_pid}；pod install 直接结束" if defined?(Pod::UI)
      return
    rescue Errno::ESRCH
      # PID 文件可以留存，进程不存在时直接启动新任务。
    rescue Errno::EPERM
      Pod::UI.puts "[CodeGraph] 后台同步已在运行，PID=#{existing_pid}；pod install 直接结束" if defined?(Pod::UI)
      return
    end
  end

  FileUtils.mkdir_p(pid_dir)
  log_io = File.open(async_log, 'w')
  pid = Process.spawn(
    { 'CODEGRAPH_AUTO_INIT' => '1', 'CODEGRAPH_EXPORT_ASYNC' => '0' },
    script_path,
    chdir: __dir__,
    in: File::NULL,
    out: log_io,
    err: log_io,
    pgroup: true
  )
  Process.detach(pid)
  File.write(pid_path, "#{pid}\n")
  Pod::UI.puts "[CodeGraph] 后台同步已启动，PID=#{pid}，日志=#{async_log}" if defined?(Pod::UI)
  Pod::UI.puts '[CodeGraph] pod install 主流程已完成，无需等待 CodeGraph' if defined?(Pod::UI)
rescue => e
  Pod::UI.puts "[CodeGraph] ⚠️ 后台任务启动失败，已跳过：#{e.message}" if defined?(Pod::UI)
ensure
  log_io&.close
end

# 统一写入 build settings（对某个 target 的所有 config）。
def jobs_apply_build_settings!(target, settings)
  target.build_configurations.each do |config|
    settings.each { |k, v| config.build_settings[k] = v }
  end
end

# 给宿主工程写入设置。
def jobs_patch_user_projects!(installer)
  installer.aggregate_targets.each do |agg|
    next unless (user_project = agg.user_project)

    user_project.native_targets.each do |target|
      jobs_apply_build_settings!(
        target,
        {
          'ENABLE_USER_SCRIPT_SANDBOXING' => JOBS_DISABLE_SCRIPT_SANDBOXING,
          'IPHONEOS_DEPLOYMENT_TARGET'    => JOBS_DEPLOYMENT_TARGET
        }
      )
    end

    user_project.save
  end
end

# 给 Pods 工程写入设置。
def jobs_patch_pods_project!(installer)
  pods_project = installer.pods_project
  pods_project.targets.each do |target|
    jobs_apply_build_settings!(
      target,
      {
        'ENABLE_USER_SCRIPT_SANDBOXING' => JOBS_DISABLE_SCRIPT_SANDBOXING,
        'IPHONEOS_DEPLOYMENT_TARGET'    => JOBS_DEPLOYMENT_TARGET
      }
    )
  end
  pods_project.save
end

# 在 Pods 分组里展示 Podfile.deps，方便继续保持依赖清单解耦。
def jobs_show_deps_file_in_pods_group!(installer)
  pods_project = installer.pods_project
  main_group = pods_project.main_group
  deps_relpath = '../Podfile.deps'

  file_ref = main_group.find_file_by_path(deps_relpath) || main_group.new_file(deps_relpath)
  file_ref.explicit_file_type = 'text.script.ruby' if file_ref.respond_to?(:explicit_file_type=)
  pods_project.save
end

# 加载拆分出来的依赖定义；本工程 Podfile.deps 目前只声明空依赖目标。
deps_candidates = [
  File.join(__dir__, 'Podfile.deps'),
  File.join(__dir__, 'Podfile.deps.rb'),
]
deps_path = deps_candidates.find { |path| File.exist?(path) }
if deps_path
  puts "📦 [Podfile] Load: #{deps_path}"
  instance_eval(File.read(deps_path), deps_path, 1)
else
  puts "⚠️  [Podfile] 找不到 Podfile.deps / Podfile.deps.rb（将跳过依赖定义加载；请确认文件已在工程根目录）"
end

post_install do |installer|
  jobs_patch_user_projects!(installer)
  jobs_patch_pods_project!(installer)
  jobs_show_deps_file_in_pods_group!(installer)
end

post_integrate do |_installer|
  run_codegraph_init_script
end
