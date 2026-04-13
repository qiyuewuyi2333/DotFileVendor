local wezterm = require 'wezterm'
local colors  = require 'colors'

local M = {}

function M.apply_to_config(config)
  -- ── 配色方案 ──────────────────────────────────────────────────────────────
  config.color_scheme = 'Catppuccin Mocha'

  -- Tab Bar 颜色覆盖（与 tabs.lua 的 format-tab-title 事件配合）
  config.colors = {
    tab_bar = {
      background        = colors.crust,
      active_tab        = { bg_color = colors.blue,     fg_color = colors.base,     intensity = 'Bold' },
      inactive_tab      = { bg_color = colors.mantle,   fg_color = colors.subtext0 },
      inactive_tab_hover = { bg_color = colors.surface0, fg_color = colors.text,    italic = false },
      new_tab           = { bg_color = colors.crust,    fg_color = colors.blue },
      new_tab_hover     = { bg_color = colors.surface0, fg_color = colors.text,     italic = false },
    },
  }

  -- ── 窗口外观 ──────────────────────────────────────────────────────────────
  -- 背景透明度：0.94 在 Acrylic/毛玻璃下效果最佳，纯色背景下也不失可读性
  config.window_background_opacity = 0.94
  -- 文字背景始终不透明，防止文字因透明度叠加变得模糊难读
  config.text_background_opacity   = 1.0

  -- ── Tab Bar 行为 ──────────────────────────────────────────────────────────
  -- 使用自定义 format-tab-title 事件，必须关闭 fancy tab bar
  config.use_fancy_tab_bar          = false
  config.hide_tab_bar_if_only_one_tab = false
  config.tab_max_width              = 32
  -- Tab Bar 位于顶部（默认），不额外配置则保持顶部
  config.tab_bar_at_bottom          = false

  -- ── 窗口边距 ──────────────────────────────────────────────────────────────
  -- top=0 让 Tab Bar 紧贴顶部，left/right 留出视觉呼吸感
  config.window_padding = {
    left   = 10,
    right  = 10,
    top    = 0,
    bottom = 6,
  }

  -- ── 光标 ──────────────────────────────────────────────────────────────────
  -- BlinkingBar 在编辑时提供清晰的位置感，500ms 是人眼感知最自然的频率
  config.default_cursor_style    = 'BlinkingBar'
  config.cursor_blink_rate       = 500
  -- Constant 缓动：光标无渐变闪烁，视觉更锐利，避免 GPU 额外渐变计算
  config.cursor_blink_ease_in    = 'Constant'
  config.cursor_blink_ease_out   = 'Constant'

  -- ── 终端行为 ──────────────────────────────────────────────────────────────
  config.audible_bell = 'Disabled'
  config.visual_bell  = {
    fade_in_function    = 'EaseIn',
    fade_in_duration_ms = 80,
    fade_out_function   = 'EaseOut',
    fade_out_duration_ms = 120,
  }

  -- SHIFT 键允许绕过应用的鼠标事件捕获（vim/tmux 中可直接选中文本）
  config.bypass_mouse_reporting_modifiers = 'SHIFT'

  -- 双击选词边界：包含常见编程符号，方便快速选中路径、变量名
  config.selection_word_boundary = " \t\n{}[]()\"'`,;:"
end

return M
