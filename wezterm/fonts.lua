local wezterm = require 'wezterm'

local M = {}

function M.apply_to_config(config)
  -- 字体回退链：优先使用 JetBrains Mono 渲染 ASCII，
  -- Maple Mono NF CN 负责 Nerd Font 图标与中文，
  -- 后续回退确保极端情况下不出现豆腐块
  config.font = wezterm.font_with_fallback({
    -- 主字体：JetBrains Mono 的连字和字形是终端编程的顶级体验
    { family = 'JetBrains Mono', weight = 'Regular' },
    -- 中文 + Nerd Font 图标：Maple Mono NF CN 一体化解决
    { family = 'Maple Mono NF CN', weight = 'Regular' },
    -- 备用中文：更广泛的字形覆盖
    { family = 'Sarasa Mono SC' },
    { family = 'Noto Sans Mono CJK SC' },
    -- 终极回退
    { family = 'Consolas' },
  })

  config.font_size   = 13.0
  -- 1.08 行高在高分屏上视觉舒适，不会让行间距过于拥挤
  config.line_height = 1.08
  config.cell_width  = 1.0

  -- 开启 OpenType 特性：
  --   calt = Contextual Alternates（上下文替换，JetBrains Mono 连字依赖此项）
  --   clig = Contextual Ligatures
  --   liga = Standard Ligatures（-> => != 等符号连字）
  config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

  -- 粗体/斜体的独立字体规则，避免 WezTerm 自动合成伪粗体（视觉质量更高）
  config.font_rules = {
    {
      intensity = 'Bold',
      italic    = false,
      font      = wezterm.font('JetBrains Mono', { weight = 'Bold' }),
    },
    {
      intensity = 'Normal',
      italic    = true,
      font      = wezterm.font('JetBrains Mono', { italic = true }),
    },
    {
      intensity = 'Bold',
      italic    = true,
      font      = wezterm.font('JetBrains Mono', { weight = 'Bold', italic = true }),
    },
  }
end

return M
