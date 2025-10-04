local colors = require("colors")

-- Default item settings
sbar.default({
  icon = {
    font = {
      family = "FiraCode Nerd Font Mono",
      style = "Regular",
      size = 16.0,
    },
    color = colors.default.text,
    padding_left = 5,
    padding_right = 4,
    y_offset = 1,
  },
  label = {
    font = {
      family = "SF Pro",
      style = "Semibold", 
      size = 13.0,
    },
    color = colors.default.text,
    padding_left = 4,
    padding_right = 5,
    y_offset = 0,
  },
  background = {
    color = colors.default.bg,
    corner_radius = 4,
    height = 24,
    border_color = colors.default.border,
    border_width = 0,
  },
  padding_left = 4,
  padding_right = 4,
})