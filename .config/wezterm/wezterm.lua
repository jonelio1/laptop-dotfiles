local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28

config.font_size = 14
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.color_scheme = 'catppuccin-mocha'
config.window_background_opacity = 0.6

config.window_decorations = "NONE"
config.enable_tab_bar = false

return config
