local wezterm = require 'wezterm'
local mux     = wezterm.mux

local M = {}

function M.apply_to_config(_config)
  -- ── 启动时窗口居中 ────────────────────────────────────────────────────────
  -- gui-startup 在 GUI 进程首次启动时触发（不会在 config reload 时重复触发）
  wezterm.on('gui-startup', function(cmd)
    -- spawn_window 时传入 cmd 参数，保持 wezterm cli start 的参数透传
    local _, _, window = mux.spawn_window(cmd or {})

    -- call_after(0.1) 而非 call_after(0)：
    -- 给 WezTerm 渲染管线约 100ms 完成首帧布局，
    -- 确保 get_dimensions() 返回真实像素尺寸而非初始占位值
    wezterm.time.call_after(0.1, function()
      local gui_window = window:gui_window()
      if not gui_window then return end

      local dims   = gui_window:get_dimensions()
      local screens = wezterm.gui.screens()

      if not dims or not screens or not screens.active then return end

      local screen = screens.active
      local x = math.floor((screen.width  - dims.pixel_width)  / 2 + (screen.x or 0))
      local y = math.floor((screen.height - dims.pixel_height) / 2 + (screen.y or 0))

      gui_window:set_position(x, y)
    end)
  end)

  -- ── 窗口标题 ──────────────────────────────────────────────────────────────
  -- 使用活动 Pane 的标题，比默认的 "wezterm" 更具信息量
  wezterm.on('format-window-title', function(_tab, pane, _tabs, _panes, _config)
    local title = pane.title or ''
    if title == '' then
      return 'WezTerm'
    end
    return title
  end)
end

return M
