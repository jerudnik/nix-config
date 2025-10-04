# Declarative SketchyBar Lua configuration files
{ pkgs }:

{
  # Settings and events
  "sketchybar/settings.lua".text = ''
    -- SketchyBar settings and event setup
    
    -- Add aerospace workspace change event
    sbar.add("event", "aerospace_workspace_change")
    sbar.add("event", "space_windows_change")
  '';

  # Bar configuration
  "sketchybar/bar.lua".text = ''
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
  '';

  # Colors (Gruvbox Material theme)
  "sketchybar/colors.lua".text = ''
    -- Gruvbox Material color scheme
    local M = {}
    
    -- Helper function to add alpha to colors
    local function with_alpha(color, alpha)
      if alpha > 1.0 or alpha < 0.0 then
        return color
      end
      return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
    end
    
    local transparent = 0x00000000
    
    -- Base Gruvbox Material colors
    local gruvbox = {
      bg = 0xff1d2021,        -- Dark background
      bg1 = 0xff32302f,       -- Lighter background  
      bg2 = 0xff3c3836,       -- Even lighter background
      fg = 0xffd4be98,        -- Foreground text
      red = 0xffea6962,       -- Red
      green = 0xffa9b665,     -- Green
      yellow = 0xffe78a4e,    -- Yellow/orange
      blue = 0xff7daea3,      -- Blue
      purple = 0xffd3869b,    -- Purple
      aqua = 0xff89b482,      -- Aqua/teal
      orange = 0xffe78a4e,    -- Orange
      gray = 0xff928374,      -- Gray
    }
    
    -- SketchyBar color sections
    M.bar = {
      bg = with_alpha(gruvbox.bg, 0.8),
      border = transparent,
      transparent = transparent,
    }
    
    M.default = {
      text = gruvbox.fg,
      bg = gruvbox.bg1,
      border = gruvbox.bg2,
    }
    
    M.spaces = {
      icon = {
        color = gruvbox.gray,
        highlight = gruvbox.fg,
      },
      label = {
        color = gruvbox.fg,
        highlight = gruvbox.blue,
      },
      indicator = gruvbox.blue,
      active_bg = gruvbox.bg2,
    }
    
    M.widgets = {
      battery = {
        low = gruvbox.red,
        mid = gruvbox.yellow,
        high = gruvbox.green,
        icon = gruvbox.blue,
      },
      wifi = {
        icon = gruvbox.aqua,
        connected = gruvbox.green,
        disconnected = gruvbox.red,
        vpn = gruvbox.purple,
      },
      volume = {
        icon = gruvbox.purple,
        muted = gruvbox.red,
      },
      clock = {
        icon = gruvbox.blue,
        text = gruvbox.fg,
      },
      cpu = {
        icon = gruvbox.orange,
        text = gruvbox.fg,
      },
    }
    
    M.popup = {
      bg = gruvbox.bg1,
      border = gruvbox.blue,
      text = gruvbox.fg,
    }
    
    return M
  '';

  # Icons
  "sketchybar/icons.lua".text = ''
    -- Nerd Font icons for SketchyBar
    local M = {}
    
    M.separators = {
      left = "",
      right = "",
    }
    
    M.apple = ""
    
    M.wifi = {
      connected = "󰖩",
      disconnected = "󰖪",
      vpn = "󰖂",
    }
    
    M.battery = {
      full = "󰁹",
      high = "󰂂",
      mid = "󰁿",
      low = "󰁼",
      critical = "󰁺",
      charging = "󰂄",
    }
    
    M.volume = {
      high = "󰕾",
      mid = "󰖀", 
      low = "󰕿",
      muted = "󰸈",
    }
    
    M.clock = " "
    M.cpu = " "
    M.memory = "󰍛"
    
    M.aerospace = {
      workspace = "󰧨",
      focused = "󰠖",
    }
    
    M.clipboard = "󰅌"
    
    M.switch = {
      on = "󰔡",
      off = "󰔤",
    }
    
    -- App icons mapping
    M.apps = {
      ["Warp"] = "󰞷",
      ["Arc"] = "󰞯",
      ["Safari"] = "󰀹",
      ["Chrome"] = "󰊯",
      ["Firefox"] = "󰈹",
      ["Brave Browser"] = "󰞯",
      ["Finder"] = "󰀶",
      ["System Preferences"] = "󰀻",
      ["Terminal"] = "󰆍",
      ["Alacritty"] = "󰆍",
      ["iTerm"] = "󰆍",
      ["VSCode"] = "󰨞",
      ["Xcode"] = "󰀵",
      ["Obsidian"] = "󱓧",
      ["Discord"] = "󰙯",
      ["Slack"] = "󰒱",
      ["Zoom"] = "󰍩",
      ["Spotify"] = "󰓇",
      ["Music"] = "󰎆",
      ["Mail"] = "󰀪",
      ["Calendar"] = "󰃭",
      ["Photos"] = "󰉏",
      ["Preview"] = "󰉖",
      ["PDF Viewer"] = "󰈦",
      ["TextEdit"] = "󰊄",
      ["Calculator"] = "󰪚",
      ["Activity Monitor"] = "󰀫",
      ["Docker"] = "󰡨",
      ["default"] = "󰀻",
    }
    
    return M
  '';

  # Default settings
  "sketchybar/default.lua".text = ''
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
  '';

  # Items loader
  "sketchybar/items.lua".text = ''
    -- Load all SketchyBar items
    require("items.spaces")
    require("items.wifi")
    require("items.battery") 
    require("items.volume")
    require("items.system")
  '';

  # Individual item files
  "sketchybar/items/spaces.lua".text = ''
    local colors = require("colors")
    local icons = require("icons")
    
    -- Dynamic workspace creation based on AeroSpace workspaces
    sbar.exec("aerospace list-workspaces --all", function(workspaces)
      for workspace_name in workspaces:gmatch("[^\r\n]+") do
        local space = sbar.add("item", "space." .. workspace_name, {
          icon = {
            string = workspace_name,
            color = colors.spaces.icon.color,
            highlight_color = colors.spaces.icon.highlight,
            font = {
              family = "SF Pro",
              style = "Bold",
              size = 14.0,
            },
            padding_left = 8,
            padding_right = 4,
            y_offset = 0,
          },
          label = {
            string = "",
            color = colors.spaces.label.color,
            highlight_color = colors.spaces.label.highlight,
            font = {
              family = "FiraCode Nerd Font Mono",
              style = "Regular", 
              size = 12.0,
            },
            padding_left = 2,
            padding_right = 8,
            y_offset = 0,
          },
          background = {
            color = colors.bar.transparent,
            corner_radius = 4,
            height = 24,
            drawing = false,
          },
          click_script = "aerospace workspace " .. workspace_name,
          padding_left = workspace_name == "1" and 4 or 2,
          padding_right = 2,
        })
    
        -- Subscribe to workspace changes
        space:subscribe("aerospace_workspace_change", function(env)
          local is_focused = env.FOCUSED_WORKSPACE == workspace_name
          
          -- Update visual state
          space:set({
            icon = { 
              highlight = is_focused,
              color = is_focused and colors.spaces.icon.highlight or colors.spaces.icon.color,
            },
            label = { 
              highlight = is_focused,
            },
            background = {
              drawing = is_focused,
              color = is_focused and colors.spaces.active_bg or colors.bar.transparent,
            },
          })
    
          -- Animate focused workspace
          if is_focused then
            sbar.animate("tanh", 10, function()
              space:set({
                background = {
                  shadow = { distance = 2 },
                },
                y_offset = -2,
              })
              space:set({
                background = {
                  shadow = { distance = 0 },
                },
                y_offset = 0,
              })
            end)
          end
        end)
    
        -- Subscribe to window changes to show app icons
        space:subscribe("space_windows_change", function()
          sbar.exec("aerospace list-windows --format %{app-name} --workspace " .. workspace_name, function(windows)
            local app_icons = {}
            local seen_apps = {}
            
            for app_name in windows:gmatch("[^\r\n]+") do
              if not seen_apps[app_name] then
                seen_apps[app_name] = true
                local icon = icons.apps[app_name] or icons.apps["default"]
                table.insert(app_icons, icon)
              end
            end
            
            -- Update label with app icons (max 4 to prevent overflow)
            local icon_string = ""
            for i = 1, math.min(#app_icons, 4) do
              icon_string = icon_string .. app_icons[i] .. " "
            end
            
            -- Show indicator if there are more than 4 apps
            if #app_icons > 4 then
              icon_string = icon_string .. "+"
            end
            
            sbar.animate("tanh", 8, function()
              space:set({ 
                label = { 
                  string = icon_string,
                }
              })
            end)
          end)
        end)
      end
    end)
  '';

  "sketchybar/items/wifi.lua".text = ''
    local colors = require("colors")
    local icons = require("icons")
    
    -- Simple WiFi indicator
    local wifi = sbar.add("item", "widgets.wifi", {
      position = "right",
      icon = {
        string = icons.wifi.connected,
        color = colors.widgets.wifi.icon,
        padding_left = 4,
        padding_right = 4,
      },
      label = {
        drawing = false,
      },
      background = {
        drawing = false,
      },
      padding_left = 4,
      padding_right = 4,
    })
    
    -- Update WiFi status
    local function update_wifi()
      sbar.exec("networksetup -getairportnetwork en0", function(result)
        local ssid = result:match("Current Wi%-Fi Network: (.+)") or ""
        local connected = ssid ~= ""
        
        wifi:set({
          icon = {
            string = connected and icons.wifi.connected or icons.wifi.disconnected,
            color = connected and colors.widgets.wifi.connected or colors.widgets.wifi.disconnected,
          },
        })
      end)
    end
    
    wifi:subscribe({ "wifi_change", "system_woke" }, update_wifi)
    update_wifi()
  '';

  "sketchybar/items/battery.lua".text = ''
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
        local percentage = result:match("(%d+)%%") or "0"
        local percent_num = tonumber(percentage)
        local is_charging = result:match("AC Power") ~= nil
        
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
          else
            icon = icons.battery.low
            color = colors.widgets.battery.low
          end
        end
        
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
    
    battery:subscribe({ "power_source_change", "system_woke" }, update_battery)
    battery:subscribe("routine", update_battery)
    update_battery()
  '';

  "sketchybar/items/volume.lua".text = ''
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
    
    volume:subscribe("volume_change", update_volume)
    update_volume()
  '';

  "sketchybar/items/system.lua".text = ''
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
    
    clock:subscribe("routine", update_clock)
    update_clock()
  '';
}