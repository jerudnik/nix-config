-- SketchyBar Configuration
-- Lua-based configuration for SketchyBar with AeroSpace integration

-- Initialize SketchyBar settings and appearance
require("settings")
require("bar")

-- Load all items
local workspaces = require("items.aerospace")
local wifi = require("items.wifi")
local battery = require("items.battery")
local volume = require("items.volume")
local clock = require("items.clock")

-- Position items on the bar
sbar.add("bracket", "left_items", {
  workspaces[1].name, workspaces[2].name, workspaces[3].name, workspaces[4].name, workspaces[5].name,
  workspaces[6].name, workspaces[7].name, workspaces[8].name, workspaces[9].name, workspaces[10].name
}, {
  background = {
    color = 0x00000000,
  },
})

sbar.add("bracket", "right_items", {
  wifi.name,
  battery.name,
  volume.name,
  clock.name
}, {
  background = {
    color = 0x00000000,
  },
})

-- Set item positions
for i = 1, 10 do
  workspaces[i]:set({ position = "left" })
end

wifi:set({ position = "right" })
battery:set({ position = "right" })
volume:set({ position = "right" })
clock:set({ position = "right" })

-- Apply final updates
sbar.hotload(true)
print("SketchyBar configuration loaded successfully")