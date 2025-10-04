local colors = require("colors")

local format = {}

-- Default item configuration
format.default_item = {
  icon = {
    font = {
      family = "SF Pro",
      style = "Medium",
      size = 15.0,
    },
    color = colors.icon,
    padding_left = 8,
  },
  label = {
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
}

-- Create a formatted item with default styling
function format.create_item(name, overrides)
  local config = format.default_item
  
  -- Merge overrides
  if overrides then
    for key, value in pairs(overrides) do
      if type(value) == "table" and config[key] then
        -- Merge nested tables
        for sub_key, sub_value in pairs(value) do
          if not config[key] then config[key] = {} end
          config[key][sub_key] = sub_value
        end
      else
        config[key] = value
      end
    end
  end
  
  return sbar.add("item", name, config)
end

-- Apply consistent spacing to a group of items
function format.apply_spacing(items, spacing)
  spacing = spacing or 8
  for i, item in ipairs(items) do
    if i > 1 then
      item:set({ padding_left = spacing })
    end
  end
end

return format