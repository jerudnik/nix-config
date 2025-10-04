-- Nerd Font icons for SketchyBar
local M = {}

M.separators = {
  left = "",
  right = "",
}

M.apple = ""

M.wifi = {
  connected = "󰖩",
  disconnected = "󰖪",
  vpn = "󰖂",
}

M.battery = {
  full = "󰁹",
  high = "󰂂",
  mid = "󰁿",
  low = "󰁼",
  critical = "󰁺",
  charging = "󰂄",
}

M.volume = {
  high = "󰕾",
  mid = "󰖀", 
  low = "󰕿",
  muted = "󰸈",
}

M.clock = " "
M.cpu = " "
M.memory = "󰍛"

M.aerospace = {
  workspace = "󰧨",
  focused = "󰠖",
}

M.clipboard = "󰅌"

M.switch = {
  on = "󰔡",
  off = "󰔤",
}

-- App icons mapping
M.apps = {
  ["Warp"] = "󰞷",
  ["Arc"] = "󰞯",
  ["Safari"] = "󰀹",
  ["Chrome"] = "󰊯",
  ["Firefox"] = "󰈹",
  ["Brave Browser"] = "󰞯",
  ["Finder"] = "󰀶",
  ["System Preferences"] = "󰀻",
  ["Terminal"] = "󰆍",
  ["Alacritty"] = "󰆍",
  ["iTerm"] = "󰆍",
  ["VSCode"] = "󰨞",
  ["Xcode"] = "󰀵",
  ["Obsidian"] = "󱓧",
  ["Discord"] = "󰙯",
  ["Slack"] = "󰒱",
  ["Zoom"] = "󰍩",
  ["Spotify"] = "󰓇",
  ["Music"] = "󰎆",
  ["Mail"] = "󰀪",
  ["Calendar"] = "󰃭",
  ["Photos"] = "󰉏",
  ["Preview"] = "󰉖",
  ["PDF Viewer"] = "󰈦",
  ["TextEdit"] = "󰊄",
  ["Calculator"] = "󰪚",
  ["Activity Monitor"] = "󰀫",
  ["Docker"] = "󰡨",
  ["default"] = "󰀻",
}

return M