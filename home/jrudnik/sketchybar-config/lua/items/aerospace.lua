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