local wezterm = require 'wezterm'
local colors  = require 'colors'

local M = {}

-- Powerline 半圆弧分隔符（需要 Nerd Font / Maple Mono NF CN 支持）
local ARROW_LEFT  = ''   -- U+E0B2 右半圆（Tab 左侧装饰）
local ARROW_RIGHT = ''   -- U+E0B0 左半圆（Tab 右侧装饰）

-- 进程名 → Nerd Font 图标映射
-- 未匹配时回退到通用终端图标
local PROCESS_ICONS = {
  nvim      = ' ',   -- 
  vim       = ' ',
  bash      = ' ',
  zsh       = ' ',
  fish      = ' ',
  pwsh      = ' ',   -- PowerShell
  powershell = ' ',
  cmd       = ' ',
  nu        = '> ',   -- Nushell
  python    = ' ',
  python3   = ' ',
  node      = ' ',
  git       = ' ',
  ssh       = ' ',
  htop      = ' ',
  btop      = ' ',
  lazygit   = ' ',
}

-- 从 pane 标题中提取进程名并映射到图标
local function get_process_icon(pane_title)
  -- pane.title 通常格式为 "process_name: cwd" 或直接是进程名
  local process = pane_title:match('^([%w_%-%.]+)') or ''
  process = process:lower()
  return PROCESS_ICONS[process] or ' '   -- 默认终端图标
end

function M.apply_to_config(_config)
  -- format-tab-title 在每次 Tab 状态变化时触发
  -- 使用局部变量构建 cells，避免模块级全局状态污染
  wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
    local pane  = tab.active_pane
    local title = pane.title or ''
    local index = tab.tab_index + 1

    -- 根据状态选择配色
    local bg, fg
    if tab.is_active then
      bg = colors.blue
      fg = colors.base
    elseif hover then
      bg = colors.surface1
      fg = colors.text
    else
      bg = colors.surface0
      fg = colors.subtext0
    end

    -- 缩放状态指示
    local zoom_icon = pane.is_zoomed and ' ' or ''

    -- 截断标题，为序号 + 图标 + 分隔符留出空间（约 8 字符）
    local icon = get_process_icon(title)
    local display_title = wezterm.truncate_right(title, max_width - 8)

    -- Powerline 风格：[背景色→圆弧] [序号:图标 标题] [圆弧→背景色]
    -- 圆弧颜色：前景=Tab背景，背景=TabBar背景（crust）
    return {
      -- 左侧圆弧：从 crust 过渡到 Tab 背景色
      { Background = { Color = colors.crust } },
      { Foreground = { Color = bg } },
      { Text = ARROW_LEFT },

      -- Tab 内容区
      { Background = { Color = bg } },
      { Foreground = { Color = fg } },
      { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
      { Text = string.format(' %d:%s%s%s ', index, icon, zoom_icon, display_title) },

      -- 右侧圆弧：从 Tab 背景色过渡到 crust
      { Background = { Color = colors.crust } },
      { Foreground = { Color = bg } },
      { Text = ARROW_RIGHT },
    }
  end)
end

return M
