local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- ── 基础行为 ──────────────────────────────────────────────────────────────────
config.automatically_reload_config        = true
config.check_for_updates                  = false
config.window_close_confirmation          = 'NeverPrompt'
config.adjust_window_size_when_changing_font_size = false
config.scrollback_lines = 5000
-- 内容超出视口时自动显示滚动条，方便快速定位位置
config.enable_scroll_bar = true

-- ── 性能 ──────────────────────────────────────────────────────────────────────
-- WebGpu 是当前最佳渲染后端（跨平台 GPU 加速）
config.front_end     = 'WebGpu'
-- 60fps 是终端场景的黄金帧率：流畅感与功耗的最优平衡点
-- 120fps 在终端中收益极低，但 GPU 负载翻倍
config.max_fps       = 60
config.animation_fps = 60

-- ── 初始窗口尺寸 ──────────────────────────────────────────────────────────────
config.initial_cols = 110
config.initial_rows = 30

-- ── 模块化配置组装 ────────────────────────────────────────────────────────────
-- 每个模块独立职责，通过 apply_to_config 注入，互不干扰
require('platform').apply_to_config(config)
require('fonts').apply_to_config(config)
require('appearance').apply_to_config(config)
require('keys').apply_to_config(config)

-- Tab Bar 和状态栏通过注册 wezterm.on 事件生效，无需返回值
require('tabs').apply_to_config(config)
require('statusbar').apply_to_config(config)
require('events').apply_to_config(config)

return config
