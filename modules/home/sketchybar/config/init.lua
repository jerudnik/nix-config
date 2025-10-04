-- Add the sketchybar module to the package path
package.path = package.path .. ";$HOME/.local/share/sketchybar_lua/?.so"

-- Load the sketchybar Lua module
sbar = require("sketchybar")

-- Initialize SketchyBar
sbar.begin_config()

-- Load configuration modules in order
require("settings")
require("bar")
require("colors")
require("icons")
require("default")
require("items")

-- End configuration
sbar.end_config()

-- Run the event loop
sbar.event_loop()
