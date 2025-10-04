local colors = require("colors")
local icons = require("icons")

local popup_width = 250

-- Main WiFi item
local wifi = sbar.add("item", "widgets.wifi", {
  position = "right",
  icon = {
    string = icons.wifi.disconnected,
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
  popup = {
    align = "center",
    height = 120,
    y_offset = 2,
  },
  padding_left = 4,
  padding_right = 4,
})

-- Popup items for network details
local ssid_item = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    string = "SSID:",
    align = "left",
    width = popup_width / 2,
    color = colors.popup.text,
  },
  label = {
    string = "Not connected",
    width = popup_width / 2,
    align = "right",
    color = colors.popup.text,
  },
  background = {
    drawing = false,
  },
  padding_left = 10,
  padding_right = 10,
})

local ip_item = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    string = "IP:",
    align = "left", 
    width = popup_width / 2,
    color = colors.popup.text,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
    color = colors.popup.text,
  },
  background = {
    drawing = false,
  },
  padding_left = 10,
  padding_right = 10,
})

local router_item = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    string = "Router:",
    align = "left",
    width = popup_width / 2,
    color = colors.popup.text,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right", 
    color = colors.popup.text,
  },
  background = {
    drawing = false,
  },
  padding_left = 10,
  padding_right = 10,
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
    
    if connected then
      ssid_item:set({ label = { string = ssid } })
      
      -- Check for VPN
      sbar.exec("scutil --nwi | grep -m1 'utun' | awk '{ print $1 }'", function(vpn_result)
        if vpn_result ~= "" then
          wifi:set({
            icon = {
              string = icons.wifi.vpn,
              color = colors.widgets.wifi.vpn,
            },
          })
        end
      end)
    else
      ssid_item:set({ label = { string = "Not connected" } })
    end
  end)
end

-- Update IP and router information when popup is shown
local function update_network_details()
  sbar.exec("ipconfig getifaddr en0", function(ip)
    ip_item:set({ label = { string = ip ~= "" and ip or "Not available" } })
  end)
  
  sbar.exec("route get default | grep gateway | awk '{print $2}'", function(router)
    router_item:set({ label = { string = router ~= "" and router or "Not available" } })
  end)
end

-- Hide popup
local function hide_details()
  wifi:set({ popup = { drawing = false } })
end

-- Toggle popup
local function toggle_details()
  local should_draw = wifi:query().popup.drawing == "off"
  if should_draw then
    wifi:set({ popup = { drawing = true } })
    update_network_details()
  else
    hide_details()
  end
end

-- Copy to clipboard function
local function copy_to_clipboard(env)
  local label_text = sbar.query(env.NAME).label.value
  sbar.exec('echo "' .. label_text .. '" | pbcopy')
  
  -- Show copied feedback
  sbar.set(env.NAME, { 
    label = { 
      string = icons.clipboard, 
      align = "center" 
    } 
  })
  
  sbar.delay(1, function()
    sbar.set(env.NAME, { 
      label = { 
        string = label_text, 
        align = "right" 
      } 
    })
  end)
end

-- Event subscriptions
wifi:subscribe({ "wifi_change", "system_woke" }, update_wifi)
wifi:subscribe("mouse.clicked", toggle_details)

-- Allow clicking on popup items to copy values
ssid_item:subscribe("mouse.clicked", copy_to_clipboard)
ip_item:subscribe("mouse.clicked", copy_to_clipboard)
router_item:subscribe("mouse.clicked", copy_to_clipboard)

-- Initial update
update_wifi()