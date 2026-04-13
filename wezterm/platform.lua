local wezterm = require 'wezterm'

local M = {}

-- ── 用户偏好 ──────────────────────────────────────────────────────────────────
-- 在此处修改以覆盖平台默认行为，nil 表示使用平台默认值
M.prefs = {
  -- Windows 下强制使用指定 Shell，可选值示例：
  --   nil          → 使用平台默认（pwsh.exe）
  --   'bash'       → Git Bash（需在 PATH 中）
  --   'wsl'        → WSL 默认发行版
  --   'wsl2'       → WSL2（同 wsl）
  --   'nu'         → Nushell（需在 PATH 中）
  --   '/path/to/sh'→ 绝对路径指定任意可执行文件
  windows_shell = 'nu',
}

-- ── Shell 解析表 ──────────────────────────────────────────────────────────────
-- 将偏好字符串映射到实际的 default_prog 参数列表
local WINDOWS_SHELL_CMDS = {
  pwsh    = { 'pwsh.exe',                       '-NoLogo' },
  bash    = { 'bash.exe',                       '-l' },
  wsl     = { 'wsl.exe' },
  wsl2    = { 'wsl.exe' },
  nu      = { 'nu.exe' },
  cmd     = { 'cmd.exe' },
}

-- 解析 Windows Shell 偏好，返回 default_prog 列表
-- 若偏好值为绝对路径则直接使用，未识别则回退到 pwsh
local function resolve_windows_shell(pref)
  if pref == nil then
    return WINDOWS_SHELL_CMDS.pwsh
  end
  -- 绝对路径（含盘符或 / 开头）直接使用
  if pref:match('^[A-Za-z]:') or pref:match('^/') then
    return { pref, '-l' }
  end
  -- 去掉可能的 .exe 后缀再查表，保持大小写不敏感
  local key = pref:lower():gsub('%.exe$', '')
  return WINDOWS_SHELL_CMDS[key] or WINDOWS_SHELL_CMDS.pwsh
end

-- 通过 target_triple 判断当前操作系统
-- 返回 "windows" | "macos" | "linux"
function M.os()
  local triple = wezterm.target_triple
  if triple:find('windows') then
    return 'windows'
  elseif triple:find('apple') then
    return 'macos'
  else
    return 'linux'
  end
end

-- 将平台特定配置注入 config
function M.apply_to_config(config)
  local current_os = M.os()

  if current_os == 'windows' then
    -- 优先使用用户偏好，未设置则默认 pwsh
    config.default_prog = resolve_windows_shell(M.prefs.windows_shell)

    -- Windows 11 Acrylic 毛玻璃效果（比 opacity 单独使用更沉浸）
    -- 若 WezTerm 版本不支持此 API 会静默忽略
    config.win32_system_backdrop = 'Acrylic'

    -- Windows 上禁用 RESIZE 以外的原生装饰，保留拖拽调整大小
    config.window_decorations = 'RESIZE'

  elseif current_os == 'macos' then
    config.default_prog = { '/bin/zsh', '-l' }

    -- macOS 原生毛玻璃模糊（数值越大越模糊，20 是视觉与性能的平衡点）
    config.macos_window_background_blur = 20

    -- macOS 隐藏标题栏但保留交通灯按钮
    config.window_decorations = 'RESIZE|MACOS_FORCE_ENABLE_SHADOW'

  else
    -- Linux：使用用户默认 Shell
    config.default_prog = { os.getenv('SHELL') or '/bin/bash', '-l' }  -- luacheck: ignore os
    config.window_decorations = 'RESIZE'
  end
end

return M
