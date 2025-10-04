local colors = require("colors")
local icons = require("icons")

-- Battery item
local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = {
    string = icons.battery.mid,
    color = colors.widgets.battery.mid,
    padding_left = 4,
    padding_right = 2,
  },
  label = {
    string = "50%",
    color = colors.default.text,
    padding_left = 2,
    padding_right = 4,
  },
  background = {
    drawing = false,
  },
  padding_left = 4,
  padding_right = 4,
})

-- Update battery status
local function update_battery()
  sbar.exec("pmset -g batt", function(result)
    -- Parse battery percentage
    local percentage = result:match("(%d+)%%") or "0"
    local percent_num = tonumber(percentage)
    
    -- Check if charging
    local is_charging = result:match("AC Power") ~= nil
    
    -- Determine icon and color based on percentage and charging state
    local icon, color
    
    if is_charging then
      icon = icons.battery.charging
      color = colors.widgets.battery.high
    else
      if percent_num >= 90 then
        icon = icons.battery.full
        color = colors.widgets.battery.high
      elseif percent_num >= 60 then
        icon = icons.battery.high
        color = colors.widgets.battery.high
      elseif percent_num >= 30 then
        icon = icons.battery.mid
        color = colors.widgets.battery.mid
      elseif percent_num >= 15 then
        icon = icons.battery.low
        color = colors.widgets.battery.low
      else
        icon = icons.battery.critical
        color = colors.widgets.battery.low
      end
    end
    
    -- Update the item
    battery:set({
      icon = {
        string = icon,
        color = color,
      },
      label = {
        string = percentage .. "%",
        color = percent_num <= 15 and colors.widgets.battery.low or colors.default.text,
      },
    })
  end)
end

-- Subscribe to battery events
battery:subscribe({ "power_source_change", "system_woke" }, update_battery)

-- Update every 2 minutes
battery:subscribe("routine", update_battery)

-- Initial update
update_battery()