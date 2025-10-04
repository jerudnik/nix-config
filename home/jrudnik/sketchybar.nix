{ pkgs }:

{
  # Enhanced SketchyBar with Lua configuration
  home.packages = with pkgs; [
    sketchybar
    sbarlua  # Lua bindings for SketchyBar
    aerospace  # Make sure aerospace is available for scripts
  ];

  # Declarative SketchyBar configuration files
  xdg.configFile = {
    # Main SketchyBar executable configuration
    "sketchybar/sketchybarrc" = {
      text = ''
        #!/usr/bin/env ${pkgs.lua54Packages.lua}/bin/lua
        -- Enhanced SketchyBar configuration with AeroSpace integration
        package.path = package.path .. ";$HOME/.local/share/sketchybar_lua/?.so"
        
        -- Load the sketchybar Lua module
        sbar = require("sketchybar")
        
        -- Initialize SketchyBar
        sbar.begin_config()
        
        -- Load main configuration
        require("init")
        
        -- End configuration and run
        sbar.end_config()
        sbar.event_loop()
      '';
      executable = true;
    };

    # Core Lua configuration files as text
    "sketchybar/init.lua".text = ''
      -- SketchyBar Configuration
      -- Lua-based configuration for SketchyBar with AeroSpace integration

      -- Initialize SketchyBar settings and appearance
      require("settings")
      require("bar")

      -- Load all items
      local workspaces = require("items.aerospace")
      local wifi = require("items.wifi")
      local battery = require("items.battery")
      local volume = require("items.volume")
      local clock = require("items.clock")

      -- Position items on the bar
      sbar.add("bracket", "left_items", {
        workspaces[1].name, workspaces[2].name, workspaces[3].name, workspaces[4].name, workspaces[5].name,
        workspaces[6].name, workspaces[7].name, workspaces[8].name, workspaces[9].name, workspaces[10].name
      }, {
        background = {
          color = 0x00000000,
        },
      })

      sbar.add("bracket", "right_items", {
        wifi.name,
        battery.name,
        volume.name,
        clock.name
      }, {
        background = {
          color = 0x00000000,
        },
      })

      -- Set item positions
      for i = 1, 10 do
        workspaces[i]:set({ position = "left" })
      end

      wifi:set({ position = "right" })
      battery:set({ position = "right" })
      volume:set({ position = "right" })
      clock:set({ position = "right" })

      -- Apply final updates
      sbar.hotload(true)
      print("SketchyBar configuration loaded successfully")
    '';
    
    "sketchybar/settings.lua".text = ''
      -- SketchyBar Settings
      -- Set up event subscriptions and general configuration

      -- Subscribe to AeroSpace events
      sbar.exec("aerospace list-workspaces --all", function(workspaces_output)
        -- Set up automatic workspace change events from AeroSpace
        sbar.exec([[
          # Set up AeroSpace workspace change notifications
          aerospace list-workspaces --monitor focused --empty no | while read workspace; do
            sketchybar --trigger aerospace_workspace_change
          done &
        ]])
      end)

      -- Subscribe to system events
      sbar.subscribe({
        "system_woke",
        "power_source_change", 
        "volume_change",
        "wifi_change",
        "aerospace_workspace_change"
      })

      -- Set update frequency for routine updates
      sbar.hotload(true)
    '';
    
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
    
    "sketchybar/colors.lua".text = ''
      -- Gruvbox Material Theme Colors
      local colors = {
        -- Base colors
        black = 0xff1d2021,
        white = 0xffd4be98,
        red = 0xffea6962,
        green = 0xffa9b665,
        blue = 0xff7daea3,
        yellow = 0xffe78a4e,
        orange = 0xffbd6f3e,
        magenta = 0xffd3869b,
        grey = 0xff928374,

        -- UI specific colors
        bar = {
          bg = 0xf02d3136,
          border = 0xff2d3136,
        },

        popup = {
          bg = 0xff2d3136,
          border = 0xff7c6f64,
        },

        bg1 = 0xff32302f,
        bg2 = 0xff3c3836,
        
        -- Text colors
        text = 0xffd4be98,
        text_dim = 0xffa89984,
        
        -- Status colors
        icon = 0xffd4be98,
        label = 0xffd4be98,
        
        -- Workspace colors
        workspace = {
          active = 0xffa9b665,
          inactive = 0xff504945,
          occupied = 0xff7daea3,
        },
      }

      return colors
    '';

    # Individual item configurations
    "sketchybar/items/aerospace.lua".text = ''
      local colors = require("colors")

      -- AeroSpace workspaces
      local workspaces = {}

      for i = 1, 10 do
        local workspace = sbar.add("item", "workspace." .. i, {
          icon = {
            string = tostring(i),
            padding_left = 10,
            padding_right = 10,
            color = colors.workspace.inactive,
            font = {
              family = "JetBrains Mono",
              style = "Medium",
              size = 13.0,
            },
          },
          label = { drawing = false },
          background = {
            color = 0x00000000,
            border_color = 0x00000000,
            height = 24,
            corner_radius = 4,
          },
          padding_left = 2,
          padding_right = 2,
          click_script = "aerospace workspace " .. i,
        })
        workspaces[i] = workspace
      end

      -- Callback function for workspace updates
      local function update_workspaces()
        -- Get the current focused workspace
        sbar.exec("aerospace list-workspaces --focused", function(focused_output)
          local focused_workspace = tonumber(focused_output:match("%d+"))
          
          -- Get occupied workspaces
          sbar.exec("aerospace list-workspaces --occupied", function(occupied_output)
            local occupied = {}
            for workspace in occupied_output:gmatch("%S+") do
              local ws_num = tonumber(workspace)
              if ws_num then
                occupied[ws_num] = true
              end
            end
            
            -- Update each workspace appearance
            for i = 1, 10 do
              local workspace = workspaces[i]
              if workspace then
                if i == focused_workspace then
                  -- Active workspace
                  workspace:set({
                    icon = { color = colors.workspace.active },
                    background = {
                      color = colors.workspace.active,
                      border_color = colors.workspace.active,
                    },
                  })
                elseif occupied[i] then
                  -- Occupied workspace
                  workspace:set({
                    icon = { color = colors.workspace.occupied },
                    background = {
                      color = 0x00000000,
                      border_color = colors.workspace.occupied,
                    },
                  })
                else
                  -- Inactive workspace
                  workspace:set({
                    icon = { color = colors.workspace.inactive },
                    background = {
                      color = 0x00000000,
                      border_color = 0x00000000,
                    },
                  })
                end
              end
            end
          end)
        end)
      end

      -- Subscribe to workspace changes
      sbar.subscribe("aerospace_workspace_change", update_workspaces)

      -- Initial update
      update_workspaces()

      return workspaces
    '';

    "sketchybar/items/wifi.lua".text = ''
      local colors = require("colors")

      local wifi = sbar.add("item", "wifi", {
        icon = {
          string = "󰤨",
          font = {
            family = "SF Pro",
            style = "Medium",
            size = 15.0,
          },
          color = colors.icon,
          padding_left = 8,
        },
        label = {
          string = "Loading...",
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
        click_script = [[
          # Get network info and copy to clipboard
          SSID=$(networksetup -getairportnetwork en0 | awk -F": " '{print $2}')
          IP=$(ipconfig getifaddr en0 2>/dev/null || echo "No IP")
          INFO="SSID: $SSID, IP: $IP"
          echo "$INFO" | pbcopy
          sketchybar --set wifi label="Copied to clipboard"
          sleep 2
          sketchybar --trigger wifi_update
        ]],
      })

      -- Function to get WiFi signal strength icon
      local function get_wifi_icon(rssi)
        if rssi > -30 then
          return "󰤨" -- Excellent signal
        elseif rssi > -50 then
          return "󰤥" -- Good signal
        elseif rssi > -60 then
          return "󰤢" -- Fair signal
        elseif rssi > -70 then
          return "󰤟" -- Weak signal
        else
          return "󰤯" -- Very weak signal
        end
      end

      -- Function to update WiFi info
      local function update_wifi()
        sbar.exec("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I", function(wifi_info)
          local ssid = wifi_info:match("SSID: (.-)%s")
          local rssi = tonumber(wifi_info:match("agrCtlRSSI: (.-)%s"))
          
          if ssid and ssid ~= "" then
            local icon = get_wifi_icon(rssi or -100)
            local signal_text = rssi and ("(" .. rssi .. " dBm)") or ""
            
            wifi:set({
              icon = { 
                string = icon,
                color = colors.icon,
              },
              label = { 
                string = ssid .. " " .. signal_text,
                color = colors.text,
              },
            })
          else
            wifi:set({
              icon = { 
                string = "󰤭",
                color = colors.red,
              },
              label = { 
                string = "Not Connected",
                color = colors.red,
              },
            })
          end
        end)
      end

      -- Subscribe to system events and custom trigger
      sbar.subscribe("system_woke", update_wifi)
      sbar.subscribe("wifi_change", update_wifi)
      sbar.subscribe("wifi_update", update_wifi)

      -- Initial update
      update_wifi()

      return wifi
    '';

    "sketchybar/items/battery.lua".text = ''
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
    '';

    "sketchybar/items/volume.lua".text = ''
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
    '';

    "sketchybar/items/clock.lua".text = ''
      local colors = require("colors")

      local clock = sbar.add("item", "clock", {
        icon = {
          string = "󰅐",
          font = {
            family = "SF Pro",
            style = "Medium",
            size = 15.0,
          },
          color = colors.icon,
          padding_left = 8,
        },
        label = {
          string = "Loading...",
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
        update_freq = 1,
      })

      -- Function to update clock
      local function update_clock()
        sbar.exec("date '+%H:%M:%S'", function(time)
          clock:set({
            label = {
              string = time:gsub("%s+$", ""), -- Remove trailing whitespace
              color = colors.text,
            },
          })
        end)
      end

      -- Subscribe to routine updates
      clock:subscribe("routine", update_clock)

      -- Initial update
      update_clock()

      return clock
    '';
  };

  # Install sbarlua library declaratively
  home.file.".local/share/sketchybar_lua/sketchybar.so" = {
    source = "${pkgs.sbarlua}/lib/lua/5.4/sketchybar.so";
  };

  # LaunchAgent to start enhanced SketchyBar
  launchd.agents.sketchybar = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.sketchybar}/bin/sketchybar" ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}