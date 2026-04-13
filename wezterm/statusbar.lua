local wezterm = require 'wezterm'
local colors  = require 'colors'

local M = {}

-- ── 辅助：电池信息 ────────────────────────────────────────────────────────────
-- 返回格式化的电池字符串，若无电池（台式机）则返回空字符串
local function get_battery_text()
  local ok, batteries = pcall(wezterm.battery_info)
  if not ok or not batteries or #batteries == 0 then
    return ''
  end
  local b = batteries[1]
  local pct = math.floor(b.state_of_charge * 100)
  local icon
  if b.state == 'Charging' then
    icon = ' '
  elseif pct >= 80 then
    icon = ' '
  elseif pct >= 60 then
    icon = ' '
  elseif pct >= 40 then
    icon = ' '
  elseif pct >= 20 then
    icon = ' '
  else
    icon = ' '   -- 低电量警告
  end
  return string.format('%s%d%% ', icon, pct)
end

-- ── 辅助：解析 CWD URI ────────────────────────────────────────────────────────
-- pane:get_current_working_dir() 返回 URI 对象或 nil
-- 提取路径并缩短 home 目录为 ~
local function get_cwd(pane)
  local cwd_uri = pane:get_current_working_dir()
  if not cwd_uri then return '' end

  local path = tostring(cwd_uri)
  -- 去除 "file://hostname" 前缀
  path = path:gsub('^file://[^/]*', '')

  -- Windows 路径：去除首个多余的 /（如 /C:/Users/... → C:/Users/...）
  if path:match('^/[A-Za-z]:') then
    path = path:sub(2)
  end

  -- 将 home 目录缩短为 ~
  local home = os.getenv('HOME') or os.getenv('USERPROFILE') or ''
  if home ~= '' and path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end

  -- 路径过长时只保留最后 2 段
  local parts = {}
  for part in path:gmatch('[^/\\]+') do
    table.insert(parts, part)
  end
  if #parts > 2 then
    path = '…/' .. parts[#parts - 1] .. '/' .. parts[#parts]
  end

  return path ~= '' and (' ' .. path .. ' ') or ''
end

-- ── 辅助：构建区块（Powerline 风格）──────────────────────────────────────────
-- 每个区块：[分隔符] [图标+文字]
-- sep_bg: 分隔符所在背景（前一区块的背景色）
-- block_bg / block_fg: 本区块的背景/前景色
local function block(cells, sep_bg, block_bg, block_fg, text)
  if text == '' then return end
  -- Powerline 左向箭头分隔符
  table.insert(cells, { Background = { Color = sep_bg } })
  table.insert(cells, { Foreground = { Color = block_bg } })
  table.insert(cells, { Text = '' })   -- U+E0B2
  table.insert(cells, { Background = { Color = block_bg } })
  table.insert(cells, { Foreground = { Color = block_fg } })
  table.insert(cells, { Attribute = { Intensity = 'Normal' } })
  table.insert(cells, { Text = text })
end

function M.apply_to_config(_config)
  -- update-right-status 触发频率较高（每次 prompt 刷新、焦点变化等）
  -- 此处所有操作均为纯内存运算，无 I/O 阻塞
  wezterm.on('update-right-status', function(window, pane)
    local cells = {}

    -- ── 区块 1：LEADER / Key Table 模式指示 ──────────────────────────────
    local mode_text = ''
    if window:leader_is_active() then
      mode_text = '  LEADER '
    else
      local kt = window:active_key_table()
      if kt then
        mode_text = ' ' .. kt .. ' '
      end
    end

    if mode_text ~= '' then
      -- Leader 激活时使用醒目的黄色背景
      local mode_bg = window:leader_is_active() and colors.yellow or colors.mauve
      local mode_fg = colors.base
      table.insert(cells, { Background = { Color = colors.crust } })
      table.insert(cells, { Foreground = { Color = mode_bg } })
      table.insert(cells, { Text = '' })
      table.insert(cells, { Background = { Color = mode_bg } })
      table.insert(cells, { Foreground = { Color = mode_fg } })
      table.insert(cells, { Attribute = { Intensity = 'Bold' } })
      table.insert(cells, { Text = mode_text })
    end

    -- ── 区块 2：Workspace 名称 ────────────────────────────────────────────
    local workspace = window:active_workspace() or 'default'
    local prev_bg = (mode_text ~= '') and
      (window:leader_is_active() and colors.yellow or colors.mauve)
      or colors.crust
    block(cells, prev_bg, colors.blue, colors.base, '  ' .. workspace .. ' ')

    -- ── 区块 3：当前工作目录 ──────────────────────────────────────────────
    local cwd = get_cwd(pane)
    block(cells, colors.blue, colors.surface1, colors.text, cwd)

    -- ── 区块 4：电池 ──────────────────────────────────────────────────────
    local battery = get_battery_text()
    if battery ~= '' then
      block(cells, colors.surface1, colors.teal, colors.base, battery)
    end

    -- ── 区块 5：日期时间 ──────────────────────────────────────────────────
    local date = wezterm.strftime ' %Y-%m-%d %H:%M '
    local prev_block_bg = battery ~= '' and colors.teal or colors.surface1
    block(cells, prev_block_bg, colors.surface0, colors.subtext1, date)

    window:set_right_status(wezterm.format(cells))
  end)
end

return M
