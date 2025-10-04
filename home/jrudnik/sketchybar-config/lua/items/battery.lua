local colors = require("colors")

local battery = sbar.add("item", "battery", {
  icon = {
    string = "󰂎",
    font = {
      family = "SF Pro",
      style = "Medium",
      size = 15.0,
    },
    color = colors.icon,
    padding_left = 8,
  },
  label = {
    string = "100%",
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
  update_freq = 30,
})

-- Function to get battery icon based on percentage and charging status
local function get_battery_icon(percentage, charging)
  if charging then
    if percentage > 90 then
      return "󰂅" -- Charging full
    elseif percentage > 60 then
      return "󰂋" -- Charging 75%
    elseif percentage > 40 then
      return "󰂊" -- Charging 50%
    elseif percentage > 20 then
      return "󰢝" -- Charging 25%
    else
      return "󰢜" -- Charging low
    end
  else
    if percentage > 95 then
      return "󰁹" -- Full battery
    elseif percentage > 85 then
      return "󰂂" -- 90% battery
    elseif percentage > 75 then
      return "󰂁" -- 80% battery
    elseif percentage > 65 then
      return "󰂀" -- 70% battery
    elseif percentage > 55 then
      return "󰁿" -- 60% battery
    elseif percentage > 45 then
      return "󰁾" -- 50% battery
    elseif percentage > 35 then
      return "󰁽" -- 40% battery
    elseif percentage > 25 then
      return "󰁼" -- 30% battery
    elseif percentage > 15 then
      return "󰁻" -- 20% battery
    elseif percentage > 5 then
      return "󰁺" -- 10% battery
    else
      return "󰂎" -- Critical battery
    end
  end
end

-- Function to get battery color based on percentage and charging status
local function get_battery_color(percentage, charging)
  if charging then
    return colors.green
  elseif percentage <= 15 then
    return colors.red
  elseif percentage <= 25 then
    return colors.yellow
  else
    return colors.icon
  end
end

-- Function to update battery status
local function update_battery()
  sbar.exec("pmset -g batt", function(batt_info)
    local percentage = tonumber(batt_info:match("(%d+)%%"))
    local charging = batt_info:match("AC Power") ~= nil
    local time_remaining = batt_info:match("(%d+:%d+) remaining")
    
    if percentage then
      local icon = get_battery_icon(percentage, charging)
      local color = get_battery_color(percentage, charging)
      local label_text = percentage .. "%"
      
      -- Add time remaining if available and not charging
      if time_remaining and not charging then
        label_text = label_text .. " (" .. time_remaining .. ")"
      elseif charging then
        label_text = label_text .. " ⚡"
      end
      
      battery:set({
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

-- Subscribe to power events
sbar.subscribe("power_source_change", update_battery)
sbar.subscribe("system_woke", update_battery)

-- Set up routine updates
battery:subscribe({"routine", "power_source_change"}, update_battery)

-- Initial update
update_battery()

return battery