#!/bin/zsh
# shell: zsh
# 脚本自述：兼容旧 IPA 留存入口，转交同名 .command 包中的完整实现。
# 内置说明与确认由被调用脚本负责；保留全部构建环境及退出码。

# 用脚本自身位置定位新入口，避免外部调用方依赖当前工作目录。
forward_ipa_snapshot() {
  local script_path="${${(%):-%x}:A}"
  local target_script="${script_path:h}/save_device_ipa_after_build.command/save_device_ipa_after_build.command"
  if [[ ! -f "$target_script" ]]; then
    print -u2 -r -- "✖ IPA 留存脚本缺失：${target_script}"
    return 1
  fi
  /bin/zsh "$target_script" "$@"
}
# 旧入口只转发到唯一业务实现，避免两套打包逻辑漂移。
main() {
  forward_ipa_snapshot "$@" # 复用完整自述、终端确认和 Xcode 自动留存行为。
}

main "$@"
