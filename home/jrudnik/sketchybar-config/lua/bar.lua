local colors = require("colors")

-- Bar configuration
sbar.bar({
  height = 32,
  color = colors.bar.bg,
  border_color = colors.bar.border,
  border_width = 0,
  margin = 0,
  y_offset = 0,
  corner_radius = 9,
  padding_left = 0,
  padding_right = 0,
  position = "top",
  sticky = true,
  shadow = false,
  topmost = true,
  blur_radius = 20,
})