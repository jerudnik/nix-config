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