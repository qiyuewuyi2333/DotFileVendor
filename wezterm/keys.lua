local wezterm = require 'wezterm'
local act     = wezterm.action

local M = {}

-- 生成 LEADER + 数字键直跳 Tab 的绑定（1~9）
local function tab_jump_keys()
  local keys = {}
  for i = 1, 9 do
    table.insert(keys, {
      key   = tostring(i),
      mods  = 'LEADER',
      action = act.ActivateTab(i - 1),
    })
  end
  return keys
end

function M.apply_to_config(config)
  -- ── Leader 键 ─────────────────────────────────────────────────────────────
  -- Ctrl-A：Tmux 用户的肌肉记忆；1200ms 超时给足双键时间
  config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1200 }

  -- ── 主键位表 ──────────────────────────────────────────────────────────────
  local keys = {

    -- ── 复制 / 粘贴 ──────────────────────────────────────────────────────
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

    -- ── 字号控制 ─────────────────────────────────────────────────────────
    { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL', action = act.ResetFontSize },

    -- ── 清屏 ─────────────────────────────────────────────────────────────
    { key = 'k', mods = 'CTRL|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },

    -- ── 命令面板 ─────────────────────────────────────────────────────────
    { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },

    -- ── 全屏切换（ALT 高频操作）──────────────────────────────────────────
    { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
    -- 禁用 ALT+Enter 的默认行为（新建窗口），改为全屏
    -- 新建窗口改用 LEADER+n
    { key = 'Enter', mods = 'CTRL|SHIFT', action = act.SpawnWindow },

    -- ── Pane 切换（ALT 高频，vim 方向键）────────────────────────────────
    { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },

    -- ── Pane 大小调整（ALT + 方向键）────────────────────────────────────
    { key = 'LeftArrow',  mods = 'ALT', action = act.AdjustPaneSize { 'Left',  5 } },
    { key = 'DownArrow',  mods = 'ALT', action = act.AdjustPaneSize { 'Down',  3 } },
    { key = 'UpArrow',    mods = 'ALT', action = act.AdjustPaneSize { 'Up',    3 } },
    { key = 'RightArrow', mods = 'ALT', action = act.AdjustPaneSize { 'Right', 5 } },

    -- ── Tab 切换（ALT 高频）──────────────────────────────────────────────
    { key = 'H', mods = 'ALT', action = act.ActivateTabRelative(-1) },
    { key = 'L', mods = 'ALT', action = act.ActivateTabRelative(1) },

    -- ── Tab 导航器（ALT+m，快速预览所有 Tab）────────────────────────────
    { key = 'm', mods = 'ALT', action = act.ShowTabNavigator },

    -- ── 新建 Tab（ALT+t，最高频操作）────────────────────────────────────
    { key = 't', mods = 'ALT', action = act.SpawnTab 'CurrentPaneDomain' },

    -- ── 关闭 Pane（ALT+w）───────────────────────────────────────────────
    { key = 'w', mods = 'ALT', action = act.CloseCurrentPane { confirm = true } },

    -- ── 分屏（ALT 触发，d=水平，D=垂直，与 tmux 习惯对齐）──────────────
    { key = 'd', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'D', mods = 'ALT', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

    -- ── 鼠标 URL 跳转 ────────────────────────────────────────────────────
    -- （在 mouse_bindings 中配置，此处不重复）

    -- ═══════════════════════════════════════════════════════════════════════
    -- LEADER 低频操作区
    -- ═══════════════════════════════════════════════════════════════════════

    -- ── Tab 管理 ─────────────────────────────────────────────────────────
    { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'x', mods = 'LEADER', action = act.CloseCurrentTab { confirm = false } },
    { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

    -- ── 分屏 ─────────────────────────────────────────────────────────────
    { key = '-',  mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'z',  mods = 'LEADER', action = act.TogglePaneZoomState },

    -- ── Pane 关闭（LEADER 版，无需确认）─────────────────────────────────
    { key = 'X', mods = 'LEADER', action = act.CloseCurrentPane { confirm = false } },

    -- ── 复制模式 / 搜索 ──────────────────────────────────────────────────
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
    { key = '/', mods = 'LEADER', action = act.Search { CaseInSensitiveString = '' } },

    -- ── Quick Select（快速选取 URL / 路径 / 哈希）────────────────────────
    { key = 's', mods = 'LEADER', action = act.QuickSelect },

    -- ── Workspace 切换器（模糊搜索所有 Workspace）───────────────────────
    { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },

    -- ── 新建窗口 ─────────────────────────────────────────────────────────
    { key = 'Enter', mods = 'LEADER', action = act.SpawnWindow },

    -- ── 重载配置 ─────────────────────────────────────────────────────────
    { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
  }

  -- 合并 LEADER + 1~9 直跳 Tab
  for _, k in ipairs(tab_jump_keys()) do
    table.insert(keys, k)
  end

  config.keys = keys

  -- ── 鼠标绑定 ──────────────────────────────────────────────────────────────
  config.mouse_bindings = {
    -- Ctrl + 左键单击打开 URL
    {
      event  = { Up = { streak = 1, button = 'Left' } },
      mods   = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
    },
  }
end

return M
