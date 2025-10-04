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

    -- Click animation
    space:subscribe("mouse.clicked", function()
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
    end)
  end
end)

-- Add workspace indicator
local workspace_indicator = sbar.add("item", "workspace_indicator", {
  icon = {
    string = icons.aerospace.workspace,
    color = colors.spaces.indicator,
    padding_left = 8,
    padding_right = 4,
  },
  label = {
    drawing = false,
  },
  background = {
    drawing = false,
  },
  padding_right = 4,
  position = "left",
})