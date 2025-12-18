return function(wezterm, config)
	-- 默认的长宽
	config.initial_cols = 120
	config.initial_rows = 28

	config.window_decorations = "RESIZE"
	-- 关掉才可以有顶部栏的样式调整
	config.use_fancy_tab_bar = false
	config.tab_max_width = 25
	config.hide_tab_bar_if_only_one_tab = false
	config.font_size = 12
	config.color_scheme = 'Catppuccin Mocha'
	config.font = wezterm.font('JetBrains Mono', { weight = 'Bold', italic = true })
	config.default_prog = { 'C:\\Users\\qiyuewuyi\\AppData\\Local\\Programs\\nu\\bin\\nu.exe' }

	-- 标签栏与窗口边缘的空隙
	config.window_padding = {
		top = 0,
	}
end
