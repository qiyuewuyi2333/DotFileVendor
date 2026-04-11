local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ========== 基础 ==========
config.automatically_reload_config = true
config.check_for_updates = false
config.window_close_confirmation = 'NeverPrompt'
config.adjust_window_size_when_changing_font_size = false
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32

-- ========== 性能 ==========
config.front_end = 'WebGpu'
config.animation_fps = 120
config.max_fps = 120

-- ========== Size ==========
config.initial_cols = 110
config.initial_rows = 30

wezterm.on('gui-startup', function()
  local _, _, window = mux.spawn_window({
    width = config.initial_cols,
    height = config.initial_rows,
  })

  wezterm.time.call_after(0, function()
    local gui_window = window:gui_window()
    if not gui_window then
      return
    end

    local dims = gui_window:get_dimensions()
    local screens = wezterm.gui.screens()

    if not dims or not screens or not screens.active then
      return
    end

    local screen = screens.active
    local x = math.floor((screen.width - dims.pixel_width) / 2 + (screen.x or 0))
    local y = math.floor((screen.height - dims.pixel_height) / 2 + (screen.y or 0))

    gui_window:set_position(x, y)
  end)
end)



-- ========== 字体 ==========
config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  'Maple Mono NF CN',
  'Sarasa Mono SC',
  'Noto Sans Mono CJK SC',
  'Consolas',
})
config.font_size = 13.0
config.line_height = 1.08
config.cell_width = 1.0
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- ========== 配色 ==========
config.color_scheme = 'Catppuccin Mocha'

config.colors = {
  tab_bar = {
    background = '#11111b',
    active_tab = {
      bg_color = '#89b4fa',
      fg_color = '#1e1e2e',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#181825',
      fg_color = '#a6adc8',
    },
    inactive_tab_hover = {
      bg_color = '#313244',
      fg_color = '#cdd6f4',
      italic = false,
    },
    new_tab = {
      bg_color = '#11111b',
      fg_color = '#89b4fa',
    },
    new_tab_hover = {
      bg_color = '#313244',
      fg_color = '#cdd6f4',
      italic = false,
    },
  },
}

config.window_background_opacity = 0.94
config.text_background_opacity = 1.0
config.macos_window_background_blur = 20

-- ========== 窗口边距 ==========
config.window_padding = {
  left = 10,
  right = 10,
  top = 8,
  bottom = 6,
}

-- ========== 光标 ==========
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- ========== 终端行为 ==========
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 80,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 120,
}
config.bypass_mouse_reporting_modifiers = 'SHIFT'
config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

-- ========== 默认启动程序（按需修改） ==========
if wezterm.target_triple:find('windows') then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
else
  config.default_prog = { '/bin/zsh', '-l' }
end

-- ========== Leader 键 ==========
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1200 }

config.keys = {
  -- 复制/粘贴
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

  -- 字号控制
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },

  -- 标签页
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentTab { confirm = false } },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

  -- 分屏
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- pane 切换（vim风格）
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- pane 大小调整
  { key = 'H', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'J', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 3 } },
  { key = 'K', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 3 } },
  { key = 'L', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- 清屏
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },

  -- 复制模式/搜索
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = '/', mods = 'LEADER', action = act.Search { CaseInSensitiveString = '' } },

  -- 快速启动器
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },

  -- 重载配置
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },

  -- 新窗口
  { key = 'Enter', mods = 'ALT', action = act.SpawnWindow },

  -- 关闭 pane
  { key = 'x', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = false } },
}

-- ========== 鼠标 ==========
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- ========== 标签标题美化 ==========
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local index = tab.tab_index + 1
  local pane = tab.active_pane
  local title = pane.title
  local zoomed = ''
  if tab.active_pane.is_zoomed then
    zoomed = '🔍 '
  end

  local background = '#181825'
  local foreground = '#a6adc8'

  if tab.is_active then
    background = '#89b4fa'
    foreground = '#1e1e2e'
  elseif hover then
    background = '#313244'
    foreground = '#cdd6f4'
  end

  title = wezterm.truncate_right(title, max_width - 6)

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = ' ' .. index .. ':' .. zoomed .. title .. ' ' },
  }
end)

-- ========== 右下角状态栏 ==========
wezterm.on('update-right-status', function(window, pane)
  local workspace = window:active_workspace()
  local key_table = window:active_key_table()
  local leader = ''

  if window:leader_is_active() then
    leader = 'LEADER '
  end

  local mode = key_table and ('TABLE:' .. key_table) or ''
  local cwd_uri = pane:get_current_working_dir()
  local cwd = ''

  if cwd_uri then
    cwd = tostring(cwd_uri):gsub('file://[^/]*', '')
  end

  local date = wezterm.strftime '%Y-%m-%d %H:%M'

  window:set_right_status(wezterm.format({
    { Foreground = { Color = '#a6adc8' } },
    { Text = ' ' .. leader },
    { Foreground = { Color = '#f9e2af' } },
    { Text = mode ~= '' and (mode .. ' ') or '' },
    { Foreground = { Color = '#89b4fa' } },
    { Text = workspace .. ' ' },
    { Foreground = { Color = '#94e2d5' } },
    { Text = cwd ~= '' and (cwd .. ' ') or '' },
    { Foreground = { Color = '#cdd6f4' } },
    { Text = date .. ' ' },
  }))
end)

-- ========== 智能窗口标题 ==========
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  return pane.title or 'WezTerm'
end)


return config
