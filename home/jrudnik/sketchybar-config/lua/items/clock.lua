local colors = require("colors")

local clock = sbar.add("item", "clock", {
  icon = {
    string = "󰅐",
    font = {
      family = "SF Pro",
      style = "Medium",
      size = 15.0,
    },
    color = colors.icon,
    padding_left = 8,
  },
  label = {
    string = "Loading...",
    font = {
      family = "JetBrains Mono",
      style = "Medium",
      size = 12.0,
    },
    color = colors.text,
    padding_right = 8,
  },
  background = {
    color = colors.bg2,
    corner_radius = 6,
    height = 24,
  },
  padding_left = 4,
  padding_right = 4,
  update_freq = 1,
})

-- Function to update clock
local function update_clock()
  sbar.exec("date '+%H:%M:%S'", function(time)
    clock:set({
      label = {
        string = time:gsub("%s+$", ""), -- Remove trailing whitespace
        color = colors.text,
      },
    })
  end)
end

-- Subscribe to routine updates
clock:subscribe("routine", update_clock)

-- Initial update
update_clock()

return clock