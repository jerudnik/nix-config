local colors = require("colors")
local icons = require("icons")

-- Volume item
local volume = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    string = icons.volume.mid,
    color = colors.widgets.volume.icon,
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

-- Update volume status
local function update_volume()
  sbar.exec("osascript -e 'output volume of (get volume settings)'", function(volume_result)
    sbar.exec("osascript -e 'output muted of (get volume settings)'", function(muted_result)
      local volume_level = tonumber(volume_result) or 50
      local is_muted = muted_result == "true"
      
      local icon, color, label_text
      
      if is_muted then
        icon = icons.volume.muted
        color = colors.widgets.volume.muted
        label_text = "Muted"
      else
        if volume_level >= 70 then
          icon = icons.volume.high
        elseif volume_level >= 30 then
          icon = icons.volume.mid
        else
          icon = icons.volume.low
        end
        color = colors.widgets.volume.icon
        label_text = volume_level .. "%"
      end
      
      volume:set({
        icon = {
          string = icon,
          color = color,
        },
        label = {
          string = label_text,
          color = is_muted and colors.widgets.volume.muted or colors.default.text,
        },
      })
    end)
  end)
end

-- Subscribe to volume change events
volume:subscribe("volume_change", update_volume)

-- Initial update
update_volume()