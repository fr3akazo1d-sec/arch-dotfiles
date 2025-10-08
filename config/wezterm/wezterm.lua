-- WezTerm Configuration
-- Fr3akazo1d cybersecurity theme

local wezterm = require 'wezterm'
local config = {}

-- Font configuration
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium' })
config.font_size = 13.0

-- Color scheme - Tron theme (cyberpunk neon colors)
config.colors = {
  -- Foreground and background (from Tron theme)
  foreground = '#00fff7',  -- Cyan foreground
  background = '#141d2b',  -- Dark blue-grey background
  cursor_bg = '#ff003c',   -- Red cursor
  cursor_fg = '#141d2b',   -- Dark cursor text
  cursor_border = '#ff003c',

  selection_fg = '#141d2b', -- Dark selection text
  selection_bg = '#00bfff', -- Blue selection background

  -- Split pane divider
  split = '#44475a',

  -- ANSI colors (palette 0-7)
  ansi = {
    '#141d2b',  -- palette 0 - black
    '#ff003c',  -- palette 1 - red
    '#00ff99',  -- palette 2 - green
    '#ffe900',  -- palette 3 - yellow
    '#00bfff',  -- palette 4 - blue
    '#ff36f9',  -- palette 5 - magenta
    '#00ffd0',  -- palette 6 - cyan
    '#e0e0e0',  -- palette 7 - white
  },

  -- Bright ANSI colors (palette 8-15)
  brights = {
    '#44475a',  -- palette 8 - bright black
    '#ff6e40',  -- palette 9 - bright red
    '#00fff7',  -- palette 10 - bright green
    '#ffd700',  -- palette 11 - bright yellow
    '#40aaff',  -- palette 12 - bright blue
    '#00aaff',  -- palette 13 - bright magenta
    '#40ffd0',  -- palette 14 - bright cyan
    '#ffffff',  -- palette 15 - bright white
  },

  -- Tab bar (using Tron theme colors)
  tab_bar = {
    background = '#141d2b',
    active_tab = {
      bg_color = '#00fff7',  -- Cyan active tab
      fg_color = '#141d2b',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#44475a',
      fg_color = '#00bfff',
    },
    inactive_tab_hover = {
      bg_color = '#00bfff',
      fg_color = '#141d2b',
    },
  },
}

-- Window configuration
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"
config.window_close_confirmation = 'NeverPrompt'
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- Cursor
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500

-- Performance
config.max_fps = 120
config.animation_fps = 60

-- Terminal behavior
config.audible_bell = "Disabled"
config.check_for_updates = false

-- Window padding
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Key bindings
config.keys = {
  -- Copy/Paste
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
  
  -- New tab
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  
  -- Close tab
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = false } },
  
  -- Switch tabs
  { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  
  -- Split panes
  { key = '|', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  
  -- Navigate panes
  { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
  
  -- Close pane
  { key = 'x', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = false } },
  
  -- Zoom pane
  { key = 'z', mods = 'CTRL|SHIFT', action = wezterm.action.TogglePaneZoomState },
  
  -- Font size
  { key = '+', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },
}

-- SSH domains (for remote connections)
config.ssh_domains = {}

-- Launch menu
config.launch_menu = {
  {
    label = 'Fish Shell',
    args = { 'fish' },
  },
  {
    label = 'Bash',
    args = { 'bash' },
  },
  {
    label = 'Zsh',
    args = { 'zsh' },
  },
}

-- Set default shell to fish if available
config.default_prog = { 'fish' }

return config