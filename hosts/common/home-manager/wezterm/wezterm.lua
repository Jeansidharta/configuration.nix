local config = {}

-- config.colors = require("colors")
-- config.keys = require("keys")

config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.8
config.audible_bell = "Disabled"
config.color_scheme = "mainTheme"

-- Spawn a fish shell in login mode
-- config.default_prog = { "/usr/bin/fish", "-l" }
-- config.font = wezterm.font_with_fallback({ "JetBrains Mono", "Twitter Color Emoji" }

config.font = wezterm.font_with_fallback({ "JetBrains Mono", "NotoSans Nerd Font" })
-- config.font = wezterm.font_with_fallback({ "Symbola", "JetBrains Mono", "NotoSans Nerd Font" })
-- config.font = wezterm.font_with_fallback({ "Monocraft", "NotoSans Nerd Font" })
-- config.font = wezterm.font_with_fallback({ "IosevkaTerm Nerd Font Mono", "NotoSans Nerd Font" })

config.font_size = 14

config.front_end = "WebGpu"

return config
