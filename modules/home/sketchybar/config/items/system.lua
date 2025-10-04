local colors = require("colors")
local icons = require("icons")

-- Clock item
local clock = sbar.add("item", "widgets.clock", {
  position = "right",
  icon = {
    string = icons.clock,
    color = colors.widgets.clock.icon,
    padding_left = 4,
    padding_right = 2,
  },
  label = {
    string = "12:00 PM",
    color = colors.widgets.clock.text,
    padding_left = 2,
    padding_right = 4,
  },
  background = {
    drawing = false,
  },
  padding_left = 4,
  padding_right = 4,
  update_freq = 30,
})

-- CPU/Memory item  
local cpu = sbar.add("item", "widgets.cpu", {
  position = "right",
  icon = {
    string = icons.cpu,
    color = colors.widgets.cpu.icon,
    padding_left = 4,
    padding_right = 2,
  },
  label = {
    string = "0% 󰍛 0%",
    color = colors.widgets.cpu.text,
    padding_left = 2,
    padding_right = 4,
  },
  background = {
    drawing = false,
  },
  padding_left = 4,
  padding_right = 4,
  update_freq = 5,
})

-- Update clock
local function update_clock()
  sbar.exec("date '+%a %b %d  %I:%M %p'", function(time)
    clock:set({
      label = {
        string = time,
      },
    })
  end)
end

-- Update CPU and memory usage
local function update_cpu()
  -- Get CPU usage
  sbar.exec("ps -A -o %cpu | awk '{s+=$1} END {printf \"%.0f\", s/$(sysctl -n hw.ncpu)}'", function(cpu_usage)
    -- Get memory pressure
    sbar.exec("memory_pressure | grep 'System-wide memory free percentage:' | awk '{print 100-$5}' | cut -d'.' -f1", function(memory_usage)
      local cpu_percent = tonumber(cpu_usage) or 0
      local mem_percent = tonumber(memory_usage) or 0
      
      cpu:set({
        label = {
          string = cpu_percent .. "% " .. icons.memory .. " " .. mem_percent .. "%",
        },
      })
    end)
  end)
end

-- Subscribe to events
clock:subscribe("routine", update_clock)
cpu:subscribe("routine", update_cpu)

-- Initial updates
update_clock()
update_cpu()