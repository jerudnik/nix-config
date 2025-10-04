-- Gruvbox Material color scheme
local M = {}

-- Helper function to add alpha to colors
local function with_alpha(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then
    return color
  end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

local transparent = 0x00000000

-- Base Gruvbox Material colors
local gruvbox = {
  bg = 0xff1d2021,        -- Dark background
  bg1 = 0xff32302f,       -- Lighter background  
  bg2 = 0xff3c3836,       -- Even lighter background
  fg = 0xffd4be98,        -- Foreground text
  red = 0xffea6962,       -- Red
  green = 0xffa9b665,     -- Green
  yellow = 0xffe78a4e,    -- Yellow/orange
  blue = 0xff7daea3,      -- Blue
  purple = 0xffd3869b,    -- Purple
  aqua = 0xff89b482,      -- Aqua/teal
  orange = 0xffe78a4e,    -- Orange
  gray = 0xff928374,      -- Gray
}

-- SketchyBar color sections
M.bar = {
  bg = with_alpha(gruvbox.bg, 0.8),
  border = transparent,
  transparent = transparent,
}

M.default = {
  text = gruvbox.fg,
  bg = gruvbox.bg1,
  border = gruvbox.bg2,
}

M.spaces = {
  icon = {
    color = gruvbox.gray,
    highlight = gruvbox.fg,
  },
  label = {
    color = gruvbox.fg,
    highlight = gruvbox.blue,
  },
  indicator = gruvbox.blue,
  active_bg = gruvbox.bg2,
}

M.widgets = {
  battery = {
    low = gruvbox.red,
    mid = gruvbox.yellow,
    high = gruvbox.green,
    icon = gruvbox.blue,
  },
  wifi = {
    icon = gruvbox.aqua,
    connected = gruvbox.green,
    disconnected = gruvbox.red,
    vpn = gruvbox.purple,
  },
  volume = {
    icon = gruvbox.purple,
    muted = gruvbox.red,
  },
  clock = {
    icon = gruvbox.blue,
    text = gruvbox.fg,
  },
  cpu = {
    icon = gruvbox.orange,
    text = gruvbox.fg,
  },
}

M.popup = {
  bg = gruvbox.bg1,
  border = gruvbox.blue,
  text = gruvbox.fg,
}

return M