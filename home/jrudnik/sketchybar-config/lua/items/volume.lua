local colors = require("colors")

local volume = sbar.add("item", "volume", {
  icon = {
    string = "󰕾",
    font = {
      family = "SF Pro",
      style = "Medium",
      size = 15.0,
    },
    color = colors.icon,
    padding_left = 8,
  },
  label = {
    string = "50%",
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
  click_script = "osascript -e 'set volume output muted not (output muted of (get volume settings))'",
})

-- Function to get volume icon based on level and mute status
local function get_volume_icon(volume_level, muted)
  if muted or volume_level == 0 then
    return "󰸈" -- Muted
  elseif volume_level < 30 then
    return "󰕿" -- Low volume
  elseif volume_level < 70 then
    return "󰖀" -- Medium volume
  else
    return "󰕾" -- High volume
  end
end

-- Function to get volume color based on mute status
local function get_volume_color(muted)
  if muted then
    return colors.red
  else
    return colors.icon
  end
end

-- Function to update volume status
local function update_volume()
  sbar.exec("osascript -e 'get volume settings'", function(volume_info)
    local volume_level = tonumber(volume_info:match("output volume:(%d+)"))
    local muted = volume_info:match("output muted:true") ~= nil
    
    if volume_level then
      local icon = get_volume_icon(volume_level, muted)
      local color = get_volume_color(muted)
      local label_text = muted and "Muted" or (volume_level .. "%")
      
      volume:set({
        icon = {
          string = icon,
          color = color,
        },
        label = {
          string = label_text,
          color = color,
        },
      })
    end
  end)
end

-- Subscribe to volume change events
sbar.subscribe("volume_change", update_volume)
sbar.subscribe("system_woke", update_volume)

-- Initial update
update_volume()

return volume